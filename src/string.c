#include "types.h"
#include "x86.h"

// TODO(lizhi): what are the params?
void* memset(void* dst, int c, uint n) {
  if ((int)dst%4 == 0 && n%4 == 0){
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}

// returns 0 if the value pointed to by the two contineous memories (starts from
// v1 and v2, and lasts n bytes) are the same.
void* memcmp(const void* v1, const void* v2, uint n) {
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    if (*s1 != *s2) {
      return (void*)(*s1 - *s2);
    }
    s1++;
    s2++;
  }
  return 0;
}

// TODO(lizhi): do we really need to return?
// 
// copy |n| bytes starting from |dst| to |src|
void* memmove(void* dst, const void* src, uint n) {
  const char* s;
  char* d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    s += n;
    d += n;
    while (n-- > 0) {
      *--d = * --s;
    }
  } else {
    while (n-- > 0) {
      *d++ = *s++;
    }
  }

  return dst;
}

int strncmp(const char* p, const char* q, uint n) {
  while (n > 0 && *p && *p == *q) {
    n--;
    p++;
    q++;
  }
  if (n == 0) {
    return 0;
  }
  return (int)((uchar)*p - (uchar)*q);
}

// Copy the string at address |t| to |s|. If |t| length is smaller than |n|,
// fill in '\0' in the corresponding part of |s|.
char* strncpy(char* s, const char* t, int n) {
  char* os = s;
  while (n-- > 0 && (*s++ = *t++) != 0) {
    ;
  }
  while (n-- > 0) {
    *s++ = 0;
  }
  return os;
}
