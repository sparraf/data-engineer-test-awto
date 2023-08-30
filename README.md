# Respuestas Test Data Engineer

### 1. Diseñar un modelo de datos. Genere una propuesta sobre cómo guardar los datos. Justifique esa propuesta y explique por qué es la mejor opción.
**Respuesta:** Se propone un modelo de datos tipo estrella, representado por el siguiente diagrama:
<iframe width="700" height="350" src='https://dbdiagram.io/embed/64ee944402bd1c4a5ea4b75a'> </iframe>
En este modelo se destacan los siguientes aspectos:


- Se incluye en la tabla de hechos `fact_trips` todos los IDs asociados a sus dimensiones, junto con las mediciones de distancia recorrida, precio, y coordenadas.
- Los atributos `name_user` y `rut_user` se incluyen sólo en la dimensión `dim_users`
- Los atributos asociados a timestamps se separan en fecha y hora, y se codifican en sus respectivas tablas de dimensión `dim_date` y `dim_time`.

Los principales fundamentos para la elección de esta arquitectura son los siguientes:

- Facilita el entendimiento de cómo se encuentran estructurada la data y cómo los campos se relacionan entre sí
- Simplificación de queries en comparación a modelos de datos más normalizados al requerir menos JOINs
- Mayor flexibilidad que modelos de datos del tipo One Big Table, especialmente en el caso de requerir modificar alguna dimensión (por ejemplo, en caso de que un usuario modifique su nombre, sólo será necesario modificar una única fila de la tabla `dim_user`, en vez de modificar una gran cantidad de filas de la tabla `fact_trips`).