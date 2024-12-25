#ifndef COMPOS_LIST_IPP_
#define COMPOS_LIST_IPP_

#include "list.h"

template <typename T> List<T>::~List() {
  while (head) {
    Node *temp = head;
    head = head->next;
    delete temp;
  }
}

template <typename T> List<T> &List<T>::operator=(const List &other) {
  if (this == &other)
    return *this;

  this->~List(); // Clear Current List to take on new values

  Node *current = other.head;
  while (current) { // Copy elements from other list
    PushBack(current->data);
    current = current->next;
  }
  return *this;
}

template <typename T>
List<T>::List(const List &other) : head(nullptr), size(0) {
  Node *current = other.head;
  while (current) {
    PushBack(current->data);
    current = current->next;
  }
}

template <typename T>
List<T>::List(const List &&other) noexcept
    : head(other.head), size(other.size) {}

template <typename T> List<T> &List<T>::operator=(const List &&other) noexcept {
  if (this != &other) {
    // Clear current list
    this->~List();

    // Transfer ownership
    head = other.head;
    size = other.size;
  }
  return *this;
}

// Modify Operations
template <typename T> void List<T>::PushBack(const T &data) {
  Node *new_node = new Node{data, nullptr};
  if (!head) {
    head = new_node;
  } else {
    Node *current = head;
    while (current->next) {
      current = current->next;
    }
    current->next = new_node;
  }
  size++;
}

template <typename T> void List<T>::PushFront(const T &data) {
  Node *new_node = new Node{data, head};
  head = new_node;
  size++;
}

// Access Operations
template <typename T> constexpr T List<T>::GetBack() const noexcept {
  if (!head)
    return T{};
  Node *current = head;
  while (current->next) {
    current = current->next;
  }
  return current->data;
}

template <typename T> constexpr T List<T>::GetFront() const noexcept {
  if (!head)
    return T{};
  return head->data;
}

template <typename T>
constexpr T List<T>::AtIndex(size_t index) const noexcept {
  if (index < 0 || index >= size)
    return T{};
  Node *current = head;
  for (size_t i = 0; i < index; ++i) {
    current = current->next;
  }
  return current->data;
}

#endif // COMPOS_LIST_IPP_
