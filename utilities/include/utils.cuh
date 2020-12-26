// Copyright 2019 Emmett Lalish, Jared Hoberock and Nathan Bell of
// NVIDIA Research
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#pragma once
#include <thrust/device_vector.h>
#include <thrust/functional.h>
#include <thrust/iterator/permutation_iterator.h>
#include <thrust/iterator/zip_iterator.h>
#include <thrust/tuple.h>

#include <iostream>

namespace manifold {

inline void MemUsage() {
#ifdef __CUDA_ARCH__
  size_t free, total;
  cudaMemGetInfo(&free, &total);
  std::cout << "Using " << (total - free) / 1048575 << " Mb ("
            << float(total - free) / total << " %)" << std::endl;
#endif
}

inline void CheckDevice() {
#ifdef __CUDA_ARCH__
  cudaError_t error = cudaGetLastError();
  if (error != cudaSuccess) throw std::runtime_error(cudaGetErrorString(error));
#endif
}

template <typename... Iters>
thrust::zip_iterator<thrust::tuple<Iters...>> zip(Iters... iters) {
  return thrust::make_zip_iterator(thrust::make_tuple(iters...));
}

template <typename A, typename B>
thrust::permutation_iterator<A, B> perm(A a, B b) {
  return thrust::make_permutation_iterator(a, b);
}

template <typename T>
thrust::counting_iterator<T> countAt(T i) {
  return thrust::make_counting_iterator(i);
}

// Copied from
// https://github.com/thrust/thrust/blob/master/examples/strided_range.cu
template <typename Iterator>
class strided_range {
 public:
  typedef typename thrust::iterator_difference<Iterator>::type difference_type;

  struct stride_functor
      : public thrust::unary_function<difference_type, difference_type> {
    difference_type stride;

    stride_functor(difference_type stride) : stride(stride) {}

    __host__ __device__ difference_type
    operator()(const difference_type& i) const {
      return stride * i;
    }
  };

  typedef typename thrust::counting_iterator<difference_type> CountingIterator;
  typedef typename thrust::transform_iterator<stride_functor, CountingIterator>
      TransformIterator;
  typedef typename thrust::permutation_iterator<Iterator, TransformIterator>
      PermutationIterator;

  // type of the strided_range iterator
  typedef PermutationIterator iterator;

  // construct strided_range for the range [first,last)
  strided_range(Iterator first, Iterator last, difference_type stride)
      : first(first), last(last), stride(stride) {}
  strided_range() {}

  iterator begin(void) const {
    return PermutationIterator(
        first, TransformIterator(CountingIterator(0), stride_functor(stride)));
  }

  iterator end(void) const {
    return begin() + ((last - first) + (stride - 1)) / stride;
  }

 protected:
  Iterator first;
  Iterator last;
  difference_type stride;
};

}  // namespace manifold