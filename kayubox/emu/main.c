#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "emulation.h"

static void print_usage(const char *argv0)
{
  fprintf(stderr, "Usage: %s <program>\n", argv0);
}

static void *read_file(const char *path, long *o_len)
{
  FILE *f = fopen(path, "rb");
  if (f == NULL) {
    fprintf(stderr, "Cannot open file %s: %s (%d)\n",
      path, strerror(errno), errno);
    exit(1);
  }

  fseek(f, 0, SEEK_END);
  long len = ftell(f);
  fseek(f, 0, SEEK_SET);

  char *buf = (char *)malloc(len + 1);
  if (buf == NULL || fread(buf, len, 1, f) != 1) {
    free(buf);
    buf = NULL;
  }

  if (buf == NULL) {
    int err = (errno != 0 ? errno : ferror(f));
    fprintf(stderr, "Cannot read from file %s: %s (%d)\n",
      path, strerror(err), err);
    exit(1);
  }
  fclose(f);
  buf[len] = '\0';

  *o_len = len;
  return buf;
}

int entry_cmp(const void *a, const void *b)
{
  return ((const source_map_entry *)a)->addr -
    ((const source_map_entry *)b)->addr;
}

static source_map_entry *read_source_map(const char *path)
{
  long len = -1;
  char *contents = (char *)read_file(path, &len);
  char *end = contents + len;

  size_t cap = 4, ptr = 0;
  source_map_entry *entries = malloc(cap * sizeof(source_map_entry));

  char file[64];
  char *last_file = NULL;
  int line, last_line;
  uint32_t addr, last_addr;

  char *p = contents, *q = contents;
  while (p < end) {
    while (q < end && *q != '\n') q++;
    *q = '\0';

    // Parse
    if (sscanf(p, "%60s%d%" SCNx32, file, &line, &addr) == 3) {
      if (last_file != NULL && strcmp(last_file, file) == 0) {
        if (ptr >= cap - 1) {
          cap <<= 1;
          entries = realloc(entries, cap * sizeof(source_map_entry));
        }
        entries[ptr].addr = last_addr;
        entries[ptr].file = last_file;
        entries[ptr].line = last_line;
        ptr++;
      } else {
        last_file = strdup(file);
      }
      last_line = line;
      last_addr = addr;
    }

    p = q + 1;
  }

  qsort(entries, ptr, sizeof(source_map_entry), entry_cmp);
  for (ssize_t i = 0; i < ptr; i++)
    printf(FMT_32x " %s:%d\n",
      entries[i].addr, entries[i].file, entries[i].line);

  entries[ptr].addr = 0x0;
  entries[ptr].file = NULL;
  entries[ptr].line = 0;
  return entries;
}

int main(int argc, char *argv[])
{
  if (argc < 2) {
    print_usage(argv[0]);
    exit(0);
  }

  const char *prog_path = argv[1];
  long len = -1;
  void *contents = read_file(prog_path, &len);

  char *map_path = (char *)malloc(strlen(prog_path) + 6);
  strcpy(map_path, prog_path);
  strcat(map_path, ".map");
  source_map_entry *map_entries = read_source_map(map_path);

  fprintf(stderr, "Program size: %ld\n", len);
  run_emulation(contents, len);

  return 0;
}
