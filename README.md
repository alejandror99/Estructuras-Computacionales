# Universidad Nacional de Colombia, Estructuras Computacionales 
En este repositorio encontrarán los ejemplos y guías que se estudiarán durante el semestre, los ejemplos se dividen en dos grupos según el lenguaje de programación en el que fueron escritos: Ensamblador y C++, siendo los ejemplos en Ensamblador los que se usan para introducir a la programación en el curso mientras que los ejemplos en C++ cubren la totalidad de los temas. 
Todos los ejemplos fueron creados para la tarjeta STM32L476.
  
  Listado de ejemplos:

+ Guía 1 Instalación de la Cube IDE: Instrucciones para intalar la IDE STM32cubeIDE usada para programar las tarjetas, importar el primer proyecto y cargarlo a la tarjeta.
+ Guía 2 LED ON (s): Guía y ejemplo para encender un led usando los registros de la tarjeta usando lenguaje Ensamblador.
+ Guía 3 External Interrupt (s): Guía y ejemplo para usar la interrupción externa de la tarjeta para encender y apagar un led usando un botón con el lenguaje Ensamblador.
+ Guía 4 Timers (s y c++):Guía y ejemplo para usar los Timers de la tarjeta para hacer que un led parpadee en intervalos de tiempo constante, el ejemplo y guía estan disponibles en Ensamblador y C++.
+ Guía 5 PWM (s y c++): Guía y ejemplo para implementar un PWM usando el Timer de la tarjeta para controlar el brillo de un led usando un botón, combinando Timer e interrupción externa, el ejemplo y guía estan disponibles en Ensamblador y C++.
+ Guía 6 Semáforo: Guía y ejemplo para implementar una máquina de estados de un semáforo vehicular y un semáforo peatonal, este ejemplo y guía están disponibles en C++.
+ Guía 7 Elevador: Guía y ejemplo para implementar una máquina de estados de un elevador controlado por un solo botón, este ejemplo y guía están disponibles en C++. 
+ Guía 9 Morse: Guía y ejemplo para comunicación entre usuario y máquinas a través de código Morse, usando un botón de la tarjeta de desarrollo el usario puede enviar puntos y lineas al microcontrolador dependiendo del tiempo que permanezca presionado el botón. Este ejercicios está disponible en C++.
+ Guía 10 ADC (s): Guía y ejemplo para implementación de convertidor análogo a digital, permite convertir señales de voltaje en un pin de la tarjeta de desarrollo en un valor númerico que puede ser usado por el microcontrolador. Este ejemplo y guía esta disponible en Ensamblador.
+ Guía 11 Control Iluminación (Asignatura: Sistemas en tiempo real): Guía y ejemplo de una máquina de estados finitos, creada originalmente para la materia Sistemas en tiempo real, explica paso a paso la creación de una máquina de estados para un ejercicio simple de control de iluminación usando Timers y PWM.
