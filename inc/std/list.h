#ifndef COMPOS_LIST_H_
#define COMPOS_LIST_H_
#include "types.h"

#ifdef __cplusplus
extern "C" { // Exposed C List Implementation
#endif
typedef struct list list;

// Constructors / Destructor
extern inline list *ListInit(void);
extern inline void ListDestroy(list *list);

// Modify Operations
extern inline void ListPushBack(list *list, void *data);
extern inline void ListPushFront(list *list, void *data);

// Access Operations
extern inline void *ListGetFront(list *list);
extern inline void *ListGetBack(list *list);
extern inline void *ListAt(list *list, int index);

// List Metadata
extern inline size_t ListSize(list *list);
extern inline uint8_t ListEmpty(list *list);

#ifdef __cplusplus
} // Internal C++ List Implementation

template <typename T> constexpr bool IsDefaultConstructible() {
  return noexcept(T{});
}

template <typename T> constexpr bool IsCopyConstructible() {
  return noexcept(T(T{}));
}

template <typename T> class List {
  static_assert(IsDefaultConstructible<T>(),
                "Type T must be default constructible.");
  static_assert(IsCopyConstructible<T>(), "Type T must be copy constructible.");

public:
  // Constructor/Destructor
  constexpr List() noexcept : head(nullptr), size(0) {}
  ~List();

  // Copy Semantics
  List &operator=(const List &other);
  List(const List &other);

  // Move Semantics
  List &operator=(const List &&other) noexcept;
  List(const List &&other) noexcept;

  // Modify Operations
  void PushBack(const T &data);
  void PushFront(const T &data);
  // Access Operations
  constexpr T GetBack() const noexcept;
  constexpr T GetFront() const noexcept;
  constexpr T AtIndex(size_t index) const noexcept;

private:
  struct Node {
    T data;
    Node *next;
  };
  Node *head;
  size_t size;
};

#include "list.ipp"

#endif
#endif // COMPOS_LIST_H_
