#ifndef COMPOS_VECTOR_H_
#define COMPOS_VECTOR_H_

/** @brief Structure for a dynamic array (vector). */
typedef struct vector {
  void **data;  /**< Pointer to an array of void pointers. */
  int size;     /**< Number of elements in the vector. */
  int capacity; /**< Total allocated capacity of the vector. */
} vector;

/** @brief Initializes a new vector.
 *  @param initial_capacity Initial capacity of the vector.
 *  @return A newly initialized vector.
 */
extern struct vector VECTOR_CREATE(int initial_capacity);

/** @brief Frees all memory associated with the vector.
 *  @param vec Pointer to the vector to free.
 */
extern void VECTOR_FREE(struct vector *vec);

/** @brief Adds an element to the end of the vector.
 *  @param vec Pointer to the vector.
 *  @param element Pointer to the element to add.
 */
extern void VECTOR_PUSH_BACK(struct vector *vec, void *element);

/** @brief Removes the last element from the vector.
 *  @param vec Pointer to the vector.
 */
extern void VECTOR_POP_BACK(struct vector *vec);

/** @brief Inserts an element at a specific position in the vector.
 *  @param vec Pointer to the vector.
 *  @param index Position to insert the element.
 *  @param element Pointer to the element to insert.
 */
extern void VECTOR_INSERT(struct vector *vec, int index, void *element);

/** @brief Removes an element at a specific position in the vector.
 *  @param vec Pointer to the vector.
 *  @param index Position of the element to remove.
 */
extern void VECTOR_REMOVE(struct vector *vec, int index);

/** @brief Retrieves an element at a specific position in the vector.
 *  @param vec Pointer to the vector.
 *  @param index Position of the element to retrieve.
 *  @return Pointer to the retrieved element.
 */
extern void *VECTOR_GET(struct vector *vec, int index);

/** @brief Sets an element at a specific position in the vector.
 *  @param vec Pointer to the vector.
 *  @param index Position to set the element.
 *  @param element Pointer to the element to set.
 */
extern void VECTOR_SET(struct vector *vec, int index, void *element);

/** @brief Resizes the vector to a new capacity.
 *  @param vec Pointer to the vector.
 *  @param new_capacity New capacity of the vector.
 */
extern void VECTOR_RESIZE(struct vector *vec, int new_capacity);

/** @brief Macro for iterating through all elements in the vector.
 *  @param vec Pointer to the vector.
 *  @param i Variable used as the iterator.
 */
#define VECTOR_FOREACH(vec, i) for (int i = 0; i < (vec)->size; i++)

#endif // COMPOS_VECTOR_H_
