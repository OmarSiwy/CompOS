#include "std/list.h"

struct list {
  struct Node {
    void *data;
    Node *next;
  };

  Node *head;
  size_t size;
};

list *ListInit(void) { return new list(); }
void ListDestroy(list *list) { delete list; }

// Modify Operations
void ListPushBack(list *list, void *data) {
  list::Node *new_node = new list::Node{data, nullptr};
  if (!list->head) {
    list->head = new_node;
  } else {
    list::Node *current = list->head;
    while (current->next) {
      current = current->next;
    }
    current->next = new_node;
  }
  list->size++;
}

void ListPushFront(list *list, void *data) {
  list::Node *new_node = new list::Node{data, list->head};
  list->head = new_node;
  list->size++;
}

// Access Operations
void *ListGetFront(const list *list) {
  return list->head ? list->head->data : nullptr;
}

void *ListGetBack(const list *list) {
  if (!list->head)
    return nullptr;
  list::Node *current = list->head;
  while (current->next) {
    current = current->next;
  }
  return current->data;
}

void *ListAt(const list *list, int index) {
  if (index < 0 || static_cast<size_t>(index) >= list->size)
    return nullptr;
  list::Node *current = list->head;
  for (int i = 0; i < index; ++i) {
    current = current->next;
  }
  return current->data;
}

// List Metadata
size_t ListSize(const list *list) { return list->size; }

uint8_t ListEmpty(const list *list) { return list->size == 0; }
