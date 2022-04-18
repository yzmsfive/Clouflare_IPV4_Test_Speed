#include <cstdio>
#include <iostream>
#include <windows.system.h>

int mod;

void ipv4();
void ipv6();

int main()
{
    printf("菜单：\n1.IPV4优选测速\n2.IPV6优选测速\n请选择菜单：");
    std::cin >> mod;
    mod == 1 ? ipv4() : ipv6();
    std::cout << "Hello World!\n";
}

void ipv4()
{
    system("CF优选IP_单IPV4.bat");
}
void ipv6()
{
    system("CF优选IP_单IPV6.bat");
}