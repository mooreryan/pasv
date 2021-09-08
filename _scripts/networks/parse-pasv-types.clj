#!/usr/bin/env bb

;; Note that the counts generated by this script for
;; classes/types/groups need to be adjusted based on the number of key
;; residues in the Cytoscape node table.

(require '[clojure.string :as str])

(when (empty? (first *command-line-args*))
  (.println *err* "usage: parse-pasv-types.clj <config.edn>")
  (System/exit 1))

(def config
  (-> *command-line-args*
      first
      slurp
      clojure.edn/read-string))

(def get-pasv-signature
  (eval (:get-pasv-signature config)))

(def lines (str/split-lines (slurp (:infile config))))

(defn get-rnr-annotation [seq]
  (let [conf (:get-rnr-annotation config)
        pat (-> conf :pattern re-pattern)]
    (if (re-find pat seq) (:match conf) (:no-match conf))))

(defn chars [s] (str/split s #""))

(defn join-pairs
  ([xs ys]
   (join-pairs "" xs ys))
  ([sep xs ys]
   (map #(str/join sep [%1 %2]) xs ys)))

(defn flatten-edge [[[source target] count]]
  [source target count])

(defn flatten-node [[node {count :count degree :degree}]]
  [node count degree])

(defn new-name [collapse-these name]
  (if (contains? collapse-these name)
    (str "Other" (subs name 1))
    name))

(defn to-tsv [header data]
  (->> data
       (into [header])
       (map #(str/join "\t" %))
       (str/join "\n")))

(def key-positions
  (:key-positions config))
(def key-position-keys
  (into []
        (map #(keyword (str "pos-" %))
             key-positions)))

(def node-header ["node" "count" "degree"])
(def edge-header ["source" "target" "count"])

;; map of info from pasv-types file
(def pasv-types
  (->> lines
       (drop 1)
       (map #(str/split % #"\t"))
       (map (fn [[seq type]]
              {:seq seq :type type}))
       (map (fn [{seq :seq :as rec}]
              (assoc rec :pasv-annotation (get-rnr-annotation seq))))
       (map (fn [{type :type :as rec}]
              (let [pasv-sig (get-pasv-signature type)]
                (assoc rec :pasv-signature (join-pairs pasv-sig key-positions)))))))


;; [[source target count], ...]
(def edges
  (->> pasv-types
       (reduce (fn [all-edges {:keys [pasv-annotation pasv-signature]}]
                 (let [edges (for [key-residue pasv-signature]
                               [pasv-annotation key-residue])]
                   (into all-edges edges)))
               [])       ; [ [source, target], [source, target], ... ]
       frequencies       ; { ["RNR" "C439"] 123, ... }
       (map flatten-edge)))

;; [ [node count degree], ... ]
(def nodes
  (->> edges
       (reduce (fn [counts [source target count]]
                 (let [add-count (fnil + 0)
                       update-degree (fnil inc 0)]
                   (-> counts
                       (update-in [source :count] add-count count)
                       (update-in [source :degree] update-degree)
                       (update-in [target :count] add-count count)
                       (update-in [target :degree] update-degree))))
               {})
       (map flatten-node)))

(spit (str (:outbase config) ".nodes.tsv")
      (to-tsv node-header nodes))

(spit (str (:outbase config) ".edges.tsv")
      (to-tsv edge-header edges))

;; TODO might be better to name collapsed nodes based on their connected target.
(if (:collapse-nodes config)
  (let [collapse? (fn [[_ count degree]]
                    (and (< count (:min-count config))
                         (< degree (:min-degree config))))
        collapse-these-nodes (->> nodes
                                  (filter collapse?)
                                  (map first)
                                  (into #{}))
        filtered-edges (->> edges
                            (reduce (fn [counts [source target count]]
                                      (let [new-target (new-name collapse-these-nodes target)]
                                        (-> counts
                                            (update [source new-target] (fnil + 0) count))))
                                    {})                    ; { [source target] count, ... }
                            (map flatten-edge))
        filtered-nodes (->> nodes
                            (reduce (fn [info [node count degree]]
                                      (let [new-node (new-name collapse-these-nodes node)]
                                        (-> info
                                            (update-in [new-node :count] (fnil + 0) count)
                                            ;; This time we add up the degrees rather than
                                            ;; increment, since we're collapsing nodes into
                                            ;; a "mega" node.
                                            (update-in [new-node :degree] (fnil + 0) degree))))
                                    {}) ; { node { :count count :degree degree }, ...
                            (map flatten-node))]
    (spit (str (:outbase config) ".collapsed_nodes.tsv")
          (to-tsv node-header filtered-nodes))

    (spit (str (:outbase config) ".collapsed_edges.tsv")
          (to-tsv edge-header filtered-edges))))
