#ifndef COMPOS_UNORDERED_SET_H_
#define COMPOS_UNORDERED_SET_H_

/** @brief Structure for a node in the unordered set. */
typedef struct unordered_set_node {
  void *data; /**< Pointer to the data stored in the node. */
  struct unordered_set_node
      *next; /**< Pointer to the next node (for chaining collisions). */
} unordered_set_node;

/** @brief Structure for the unordered set. */
typedef struct unordered_set {
  int size;                     /**< Number of elements in the set. */
  int capacity;                 /**< Capacity of the hash table. */
  unordered_set_node **buckets; /**< Array of pointers to nodes (hash table). */
  unsigned int (*hash)(
      void *data);              /**< Hash function for generating indices. */
  int (*cmp)(void *a, void *b); /**< Comparison function for equality. */
} unordered_set;

/** @brief Creates a new unordered set.
 *  @param capacity Initial number of buckets in the hash table.
 *  @param hash Hash function for generating indices.
 *  @param cmp Comparison function to determine equality.
 *  @return A newly initialized unordered set.
 */
extern struct unordered_set UNORDERED_SET_CREATE(int capacity,
                                                 unsigned int (*hash)(void *),
                                                 int (*cmp)(void *, void *));

/** @brief Frees all memory associated with the unordered set.
 *  @param set Pointer to the unordered set.
 */
extern void UNORDERED_SET_FREE(struct unordered_set *set);

/** @brief Inserts a new element into the unordered set.
 *  @param data Pointer to the data to insert.
 *  @param set Pointer to the unordered set.
 */
extern void UNORDERED_SET_INSERT(void *data, struct unordered_set *set);

/** @brief Removes an element from the unordered set.
 *  @param data Pointer to the data to remove.
 *  @param set Pointer to the unordered set.
 */
extern void UNORDERED_SET_REMOVE(void *data, struct unordered_set *set);

/** @brief Checks if an element exists in the unordered set.
 *  @param data Pointer to the data to search for.
 *  @param set Pointer to the unordered set.
 *  @return 1 if the element exists, 0 otherwise.
 */
extern int UNORDERED_SET_CONTAINS(void *data, struct unordered_set *set);

/** @brief Macro for iterating through all elements in the unordered set.
 *  @param set Pointer to the unordered set.
 *  @param node Variable used as the iterator.
 *  @param bucket_index Index for iterating over the hash table buckets.
 */
#define UNORDERED_SET_FOREACH(set, node, bucket_index)                         \
  for (int bucket_index = 0; bucket_index < (set)->capacity; bucket_index++)   \
    for (unordered_set_node *node = (set)->buckets[bucket_index];              \
         node != NULL; node = node->next)

#endif // COMPOS_UNORDERED_SET_H_
