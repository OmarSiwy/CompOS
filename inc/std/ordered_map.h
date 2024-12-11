#ifndef COMPOS_ORDERED_MAP_H_
#define COMPOS_ORDERED_MAP_H_

/** @brief Structure for a node in the ordered map. */
typedef struct ordered_map_node {
  void *key;                     /**< Pointer to the key. */
  void *value;                   /**< Pointer to the value. */
  struct ordered_map_node *next; /**< Pointer to the next node. */
} ordered_map_node;

/** @brief Structure for the ordered map. */
typedef struct ordered_map {
  int size;                   /**< Number of key-value pairs in the map. */
  ordered_map_node *head;     /**< Pointer to the head node of the map. */
  int (*cmp)(void *, void *); /**< Comparison function for sorting keys. */
} ordered_map;

/** @brief Creates a new ordered map.
 *  @param cmp Comparison function for sorting keys (returns -1, 0, or 1).
 *  @return A newly initialized ordered map.
 */
extern struct ordered_map ORDERED_MAP_CREATE(int (*cmp)(void *, void *));

/** @brief Frees all memory associated with the ordered map.
 *  @param map Pointer to the ordered map to free.
 */
extern void ORDERED_MAP_FREE(struct ordered_map *map);

/** @brief Clears all elements in the ordered map but retains allocated memory.
 *  @param map Pointer to the ordered map to clear.
 */
extern void ORDERED_MAP_CLEAR(struct ordered_map *map);

/** @brief Inserts a key-value pair into the ordered map.
 *  @param key Pointer to the key.
 *  @param value Pointer to the value.
 *  @param map Pointer to the ordered map.
 */
extern void ORDERED_MAP_INSERT(void *key, void *value, struct ordered_map *map);

/** @brief Removes a key and its corresponding value from the ordered map.
 *  @param key Pointer to the key to be removed.
 *  @param map Pointer to the ordered map.
 */
extern void ORDERED_MAP_REMOVE(void *key, struct ordered_map *map);

/** @brief Finds the value corresponding to a given key.
 *  @param key Pointer to the key to search for.
 *  @param map Pointer to the ordered map.
 *  @return Pointer to the value if found, NULL otherwise.
 */
extern void *ORDERED_MAP_FIND(void *key, struct ordered_map *map);

/** @brief Counts the number of occurrences of a key in the ordered map.
 *  @param key Pointer to the key to count.
 *  @param map Pointer to the ordered map.
 *  @return The number of occurrences of the specified key.
 */
extern int ORDERED_MAP_COUNT(void *key, struct ordered_map *map);

/** @brief Macro for iterating through all nodes in the ordered map.
 *  @param map Pointer to the ordered map.
 *  @param node Variable used as the iterator.
 */
#define ORDERED_MAP_FOREACH(map, node)                                         \
  for (ordered_map_node *node = (map)->head; node != NULL; node = node->next)

/** @brief Finds the smallest key in the ordered map.
 *  @param map Pointer to the ordered map.
 *  @return Pointer to the smallest key, or NULL if the map is empty.
 */
extern void *ORDERED_MAP_MIN(struct ordered_map *map);

/** @brief Finds the largest key in the ordered map.
 *  @param map Pointer to the ordered map.
 *  @return Pointer to the largest key, or NULL if the map is empty.
 */
extern void *ORDERED_MAP_MAX(struct ordered_map *map);

#endif // COMPOS_ORDERED_MAP_H_
