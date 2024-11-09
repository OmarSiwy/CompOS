#ifndef COMPOS_LIST_H
#define COMPOS_LIST_H

/*
 * Internal Linked List Implementation, designed to be used atomically,
 * and therefore does not require volatile qualifiers.
 * To use, please enter the atomic block, then use the list function, and exit.
 */
typedef struct list_t {
  void *data;
  struct list_t *next;
  struct list_t *prev;
} list_t;

/* Access Macros */
#define listSET_LIST_ITEM_DATA(pxListItem, data) ((pxListItem)->data = (data))
#define listGET_LIST_ITEM_DATA(pxListItem) ((pxListItem)->data)

#define listGET_HEAD_ENTRY(pxList) ((pxList)->next)
#define listGET_NEXT(pxListItem) ((pxListItem)->next)
#define listLIST_IS_EMPTY(pxList) (((pxList)->next == NULL) ? pdTRUE : pdFALSE)

#define listINIT(pxList)                                                       \
  do {                                                                         \
    (pxList)->next = NULL;                                                     \
    (pxList)->prev = NULL;                                                     \
  } while (0)

#define listINSERT_HEAD(pxList, pxNewItem)                                     \
  do {                                                                         \
    (pxNewItem)->next = (pxList)->next;                                        \
    (pxNewItem)->prev = (pxList);                                              \
    if ((pxList)->next != NULL) {                                              \
      (pxList)->next->prev = (pxNewItem);                                      \
    }                                                                          \
    (pxList)->next = (pxNewItem);                                              \
  } while (0)

#define listINSERT_END(pxList, pxNewItem)                                      \
  do {                                                                         \
    list_t *pxTemp = (pxList);                                                 \
    while (pxTemp->next != NULL) {                                             \
      pxTemp = pxTemp->next;                                                   \
    }                                                                          \
    (pxTemp)->next = (pxNewItem);                                              \
    (pxNewItem)->prev = (pxTemp);                                              \
    (pxNewItem)->next = NULL;                                                  \
  } while (0)

#define listREMOVE_ITEM(pxItemToRemove)                                        \
  do {                                                                         \
    if ((pxItemToRemove)->prev != NULL) {                                      \
      (pxItemToRemove)->prev->next = (pxItemToRemove)->next;                   \
    }                                                                          \
    if ((pxItemToRemove)->next != NULL) {                                      \
      (pxItemToRemove)->next->prev = (pxItemToRemove)->prev;                   \
    }                                                                          \
    (pxItemToRemove)->next = NULL;                                             \
    (pxItemToRemove)->prev = NULL;                                             \
  } while (0)

#define listIS_CONTAINED_WITHIN(pxList, pxItem)                                \
  ({                                                                           \
    list_t *temp = (pxList);                                                   \
    bool found = false;                                                        \
    while (temp != NULL) {                                                     \
      if (temp == (pxItem)) {                                                  \
        found = true;                                                          \
        break;                                                                 \
      }                                                                        \
      temp = temp->next;                                                       \
    }                                                                          \
    found;                                                                     \
  })

#define listLENGTH(pxList)                                                     \
  ({                                                                           \
    list_t *temp = (pxList);                                                   \
    int length = 0;                                                            \
    while (temp->next != NULL) {                                               \
      length++;                                                                \
      temp = temp->next;                                                       \
    }                                                                          \
    length;                                                                    \
  })

#endif /* COMPOS_LIST_H */
