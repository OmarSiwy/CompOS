#ifndef COMPOS_UNORDERED_MAP_H_
#define COMPOS_UNORDERED_MAP_H_

/** @brief Structure for a node in the unordered map. */
typedef struct unordered_map_node {
  void *key;   /**< Pointer to the key. */
  void *value; /**< Pointer to the value. */
  struct unordered_map_node
      *next; /**< Pointer to the next node (for chaining collisions). */
} unordered_map_node;

/** @brief Structure for the unordered map. */
typedef struct unordered_map {
  int size;                     /**< Number of elements in the map. */
  int capacity;                 /**< Capacity of the hash table. */
  unordered_map_node **buckets; /**< Array of pointers to nodes (hash table). */
  unsigned int (*hash)(void *key); /**< Hash function for keys. */
  int (*cmp)(void *a, void *b);    /**< Comparison function for keys. */
} unordered_map;

/** @brief Creates a new unordered map.
 *  @param capacity Initial number of buckets in the hash table.
 *  @param hash Hash function for generating indices.
 *  @param cmp Comparison function to compare keys.
 *  @return A newly initialized unordered map.
 */
extern struct unordered_map UNORDERED_MAP_CREATE(int capacity,
                                                 unsigned int (*hash)(void *),
                                                 int (*cmp)(void *, void *));

/** @brief Frees all memory associated with the unordered map.
 *  @param map Pointer to the unordered map.
 */
extern void UNORDERED_MAP_FREE(struct unordered_map *map);

/** @brief Inserts a key-value pair into the unordered map.
 *  @param key Pointer to the key.
 *  @param value Pointer to the value.
 *  @param map Pointer to the unordered map.
 */
extern void UNORDERED_MAP_INSERT(void *key, void *value,
                                 struct unordered_map *map);

/** @brief Removes a key and its corresponding value from the unordered map.
 *  @param key Pointer to the key to remove.
 *  @param map Pointer to the unordered map.
 */
extern void UNORDERED_MAP_REMOVE(void *key, struct unordered_map *map);

/** @brief Finds the value corresponding to a key in the unordered map.
 *  @param key Pointer to the key to search for.
 *  @param map Pointer to the unordered map.
 *  @return Pointer to the value if found, NULL otherwise.
 */
extern void *UNORDERED_MAP_FIND(void *key, struct unordered_map *map);

/** @brief Macro for iterating through all elements in the unordered map.
 *  @param map Pointer to the unordered map.
 *  @param node Variable used as the iterator.
 *  @param bucket_index Index for iterating over the hash table buckets.
 */
#define UNORDERED_MAP_FOREACH(map, node, bucket_index)                         \
  for (int bucket_index = 0; bucket_index < (map)->capacity; bucket_index++)   \
    for (unordered_map_node *node = (map)->buckets[bucket_index];              \
         node != NULL; node = node->next)

#endif // COMPOS_UNORDERED_MAP_H_
