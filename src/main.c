/*
 * @Author: rx-ted
 * @Date: 2022-12-15 18:59:11
 * @LastEditors: rx-ted
 * @LastEditTime: 2022-12-15 19:38:18
 */

#include "main.h"
#include <stdint.h>
#include <stdio.h>

void led_init(void);
int i, j;

// LED 初始化程序
void led_init(void)
{
  GPIO_InitType GPIO_LED; // 定义GPIO结构体变量

  RCC_EnableAPB2PeriphClk(RCC_APB2_PERIPH_GPIOB, ENABLE); // 使能GPIOB端口的时钟

  GPIO_LED.Pin = GPIO_PIN_5;   // LED端口配置
  GPIO_LED.GPIO_Mode = GPIO_Mode_Out_PP; // 推挽输出
  GPIO_LED.GPIO_Speed = GPIO_Speed_50MHz; // IO口速度为2MHz
  GPIO_InitPeripheral(GPIOB, &GPIO_LED);           // 根据设定参数初始化GPIOB0

  GPIO_SetBits(GPIOB, GPIO_PIN_5); // GPIOB0输出高电平,初始化LED灭
}

int main(void)
{
  led_init(); // LED初始化
  while (1)
  {
    GPIO_ResetBits(GPIOB, GPIO_PIN_5); // 点亮LED
    for (i = 0; i <= 1000; i++)
      for (j = 0; j <= 2000; j++)
        ; // 软件延时一段时间

    GPIO_SetBits(GPIOB, GPIO_PIN_5); // 熄灭LED
    for (i = 0; i <= 1000; i++)
      for (j = 0; j <= 2000; j++)
        ; // 软件延时一段时间
  }
}
