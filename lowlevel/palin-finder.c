#include <stdio.h>

int len(char *s){
    int size = 0;
    while (s[size] != '\0'){
        if (s[size] >= 65 && s[size] <=90) s[size] = s[size] + 32;
        size = size + 1;
    }
    return size;
}

int palindrome(char *s, int l){
    int lp = 0;
    int rp = l-1;
    while ((s[lp] == s[rp] || s[lp] == ' ' || s[rp] == ' ') && rp >= 0){
        if (s[lp] == ' '){
            lp += 1;
        }
        else if(s[rp] == ' '){
            rp -= 1;
        }
        else{
        lp += 1;
        rp -= 1;
        }
    }
    if (rp == -1){
        return 1;
    }
    return 0;
}

int main(int argc, char *argv[]){
    char str[] = "    sKayAk      ";
    int size = len(str);
    int p = palindrome(str,size);
    printf("%i\n",p);
    return 0;
}
//Grav ned den varg
