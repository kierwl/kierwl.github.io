---
layout: single
comments: true
title: "While문과 break "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

# 정렬 알고리즘 (Sorting Algorithms)

정렬 알고리즘은 데이터를 특정한 순서(예: 오름차순, 내림차순)로 정렬하는 알고리즘입니다. 정렬은 탐색 및 데이터 분석을 용이하게 하며, 여러 알고리즘이 존재한다.

## 1. 기본 정렬 알고리즘

### 1.1. 버블 정렬 (Bubble Sort)

- **시간 복잡도:** O(n^2)
- **공간 복잡도:** O(1)
- **특징:**
  - 인접한 두 요소를 비교하여 정렬
  - 최악의 경우에도 O(n^2)로 비효율적
  - 이미 정렬된 경우 O(n)

```
void BubbleSort(int[] arr) {
    int n = arr.Length;
    for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                (arr[j], arr[j + 1]) = (arr[j + 1], arr[j]);
            }
        }
    }
}
```

### 1.2. 선택 정렬 (Selection Sort)

- **시간 복잡도:** O(n^2)
- **공간 복잡도:** O(1)
- **특징:**
  - 매번 최소/최대 값을 찾아 첫 번째 요소와 교체
  - 안정 정렬이 아님

```
void SelectionSort(int[] arr) {
    int n = arr.Length;
    for (int i = 0; i < n - 1; i++) {
        int minIndex = i;
        for (int j = i + 1; j < n; j++) {
            if (arr[j] < arr[minIndex]) {
                minIndex = j;
            }
        }
        (arr[i], arr[minIndex]) = (arr[minIndex], arr[i]);
    }
}
```

### 1.3. 삽입 정렬 (Insertion Sort)

- **시간 복잡도:** O(n^2)
- **공간 복잡도:** O(1)
- **특징:**
  - 이미 정렬된 배열에 강함 (O(n) 성능 가능)
  - 안정 정렬

```
void InsertionSort(int[] arr) {
    int n = arr.Length;
    for (int i = 1; i < n; i++) {
        int key = arr[i];
        int j = i - 1;
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j--;
        }
        arr[j + 1] = key;
    }
}
```

## 2. 고급 정렬 알고리즘

### 2.1. 병합 정렬 (Merge Sort)

- **시간 복잡도:** O(n log n)
- **공간 복잡도:** O(n)
- **특징:**
  - 분할 정복 기법 사용
  - 안정 정렬

```
void MergeSort(int[] arr, int left, int right) {
    if (left >= right) return;
    int mid = (left + right) / 2;
    MergeSort(arr, left, mid);
    MergeSort(arr, mid + 1, right);
    Merge(arr, left, mid, right);
}

void Merge(int[] arr, int left, int mid, int right) {
    List<int> temp = new();
    int i = left, j = mid + 1;
    while (i <= mid && j <= right) {
        if (arr[i] <= arr[j]) temp.Add(arr[i++]);
        else temp.Add(arr[j++]);
    }
    while (i <= mid) temp.Add(arr[i++]);
    while (j <= right) temp.Add(arr[j++]);
    for (int k = 0; k < temp.Count; k++) arr[left + k] = temp[k];
}
```

### 2.2. 퀵 정렬 (Quick Sort)

- **시간 복잡도:** O(n log n) (최악의 경우 O(n^2))
- **공간 복잡도:** O(log n)
- **특징:**
  - 피벗을 기준으로 작은 값과 큰 값으로 분할하여 정렬
  - 불안정 정렬

```
void QuickSort(int[] arr, int left, int right) {
    if (left >= right) return;
    int pivot = Partition(arr, left, right);
    QuickSort(arr, left, pivot - 1);
    QuickSort(arr, pivot + 1, right);
}

int Partition(int[] arr, int left, int right) {
    int pivot = arr[right];
    int i = left - 1;
    for (int j = left; j < right; j++) {
        if (arr[j] < pivot) {
            i++;
            (arr[i], arr[j]) = (arr[j], arr[i]);
        }
    }
    (arr[i + 1], arr[right]) = (arr[right], arr[i + 1]);
    return i + 1;
}
```

## 3. 정렬 알고리즘 비교

| 정렬 알고리즘 | 평균 시간 복잡도 | 최악 시간 복잡도 | 공간 복잡도 | 안정성 |
| ------------- | ---------------- | ---------------- | ----------- | ------ |
| 버블 정렬     | O(n²)            | O(n²)            | O(1)        | O      |
| 선택 정렬     | O(n²)            | O(n²)            | O(1)        | X      |
| 삽입 정렬     | O(n²)            | O(n²)            | O(1)        | O      |
| 병합 정렬     | O(n log n)       | O(n log n)       | O(n)        | O      |
| 퀵 정렬       | O(n log n)       | O(n²)            | O(log n)    | X      |

## 4. 정렬 알고리즘 선택 기준

- **데이터가 거의 정렬되어 있다면?** → 삽입 정렬
- **메모리를 많이 사용할 수 없는 경우?** → 퀵 정렬
- **안정성이 중요한 경우?** → 병합 정렬
- **단순한 구현이 필요할 때?** → 선택 정렬 or 버블 정렬
