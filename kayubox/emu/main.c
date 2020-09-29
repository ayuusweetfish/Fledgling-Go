#include <stdio.h>
#include <stdlib.h>

void run_emulation(const char *program, long program_size);

static void print_usage(const char *argv0)
{
  fprintf(stderr, "Usage: %s <program>\n", argv0);
}

static void *read_file(FILE *f, long *o_len)
{
  fseek(f, 0, SEEK_END);
  long len = ftell(f);
  fseek(f, 0, SEEK_SET);

  char *buf = (char *)malloc(len);
  if (buf == NULL) return NULL;

  if (fread(buf, len, 1, f) != 1) {
    free(buf);
    return NULL;
  }

  *o_len = len;
  return buf;
}

int main(int argc, char *argv[])
{
  if (argc < 2) {
    print_usage(argv[0]);
    exit(0);
  }

  const char *prog_path = argv[1];
  FILE *f = fopen(prog_path, "r");
  if (f == NULL) {
    fprintf(stderr, "Cannot open file %s\n", prog_path);
    exit(1);
  }

  long len = -1;
  char *contents = read_file(f, &len);
  if (contents == NULL) {
    fprintf(stderr, "Cannot read from file %s\n", prog_path);
    exit(1);
  }
  fclose(f);

  fprintf(stderr, "Program size: %ld\n", len);
  run_emulation(contents, len);

  return 0;
}
