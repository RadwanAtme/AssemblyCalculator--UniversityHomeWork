#include <stdio.h>
#include <stdlib.h>
#define MAX_LEN 100

void calc_expr(long long (*string_convert)(char*), int (*result_as_string)(long long));

/*
 * This variable will not change.
 */
char what_to_print[MAX_LEN];

/*
 * This is an example for an implementation of string_convert(char* num).
 * BE CAREFUL - this implementation can be different in other tests.
 * The function declaration will (of course) always be the same and the return value will always be the conversion of
 * the string num into a 10 base representation long long variable.
 */
long long string_convert(char* num) {
    return strtol(num, NULL, 10);
}

/*
 * This is an example for an implementation of result_as_string(long long num).
 * BE CAREFUL - this implementation can be different in other tests.
 * The function declaration will (of course) always be the same and the return value will always be the length
 * of the string that was copied into 'what_to_print'
 */
int result_as_string(long long num) {
    return snprintf(what_to_print, MAX_LEN, "Result is: %lld\n", num);
}

int main() {
    calc_expr(&string_convert, &result_as_string);
    return 0;
}