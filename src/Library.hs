module Library where
import PdePreludat



-- Data Accion, dado por el enunciado

data Accion = Accion {
   simbolo :: String,
   precios :: [Number]
} deriving Show



-- Punto 1
-- Generar los tipos y estructuras necesarios para modelar los usuarios y sus títulos.

data Usuario = Usuario {
    efectivo :: Number,
    listaDeTitulos :: [Titulo]
}

data Titulo = Titulo {
    simboloAccion :: String,
    cantidad :: Number,
    precio :: Number
}


-- Punto 2
-- Implementar las funciones:

-- 2.1 mapCondicional
-- mapCondicional  transformacion       condicion        lista
mapCondicional ::    (a -> a)     ->  ( a -> Bool )  ->   [a]   ->  [a]

-- version 1: 
-- * mantiene la misma cantidad de elementos que la lista original
-- * NO mantiene el orden de los elementos (no se pedía hacerlo, pero es una consecuencia de esta solución)
mapCondicional transformacion condicion lista = 
    map transformacion (filter condicion lista) ++ filter (not.condicion) lista

-- version 2:
-- * mantiene la misma cantidad de elementos que la lista original
-- * respeta el orden de los elementos de la lista, recorriendola una solo una vez
mapCondicional' transformacion condicion = map (transformarSegun transformacion condicion)

transformarSegun transformacion condicion elemento
    | condicion elemento = transformacion elemento
    | otherwise          = elemento


-- 2.2 encontrar
-- * Asumimos que existe el elemento en la lista. 
-- Offtopic: Para hacer algo así que soporte la ausencia de un valor que cumpla la condición, pueden googlear sobre mónadas 
-- ...o quizás haya una clase bonus al respecto

-- version 1:
encontrar condicion lista = head $ filter condicion lista

-- version 2:
-- * Hace lo mismo que la versión anterior pero aprovechando la composición y la notación point free
encontrar' condicion = head.filter condicion

-- version 3:
-- * Es igual de válida que la anterior, solo que el $ no es necesario por estar parcialmente aplicada, pero de usarlo obliga a usar paréntesis también
encontrar'' condicion = (head.filter condicion $)

-- version 4:
-- * Esta es incorrecta porque devuelve una lista (porque take devuelve una lista)
encontrar''' condicion lista = take 1 (filter condicion lista)  

-- version 5:
-- * Es válida pero tiene cierta complejidad al leer que puede confundir, ya que compone una función de 2 parámetros
-- Nota: la función (!!) recibe una lista y un numero, y devuelve el elemento de la lista que está en el índice indicado por el número (arrancando en 0)
encontrar'''' condicion lista = ((!!).filter condicion) lista 0


-- 2.3 cuantasTieneDe

-- version 1:
-- * Al usar la función 'encontrar' se asume que el usuario tiene títulos de ese símbolo
-- * Solo busca el primer título del usuario que tenga ese símbolo, no tiene en cuenta si compró dos veces ciertas acciones (con el mismo símbolo) a precios distintos
cuantasTieneDe simb = cantidad . encontrar ((==simb).simboloAccion) . listaDeTitulos

-- version 2:
-- * Soporta que el usuario haya comprado varias veces la misma accion, posiblemente a precios distintos
cuantasTieneDe' :: String -> Usuario -> Number
cuantasTieneDe' simbolo = sum . map cantidad . filter condicion . listaDeTitulos
    where condicion titulo =  simboloAccion titulo == simbolo

-- version 3:
-- * Esta devuelve la cantidad de titulos con ese simbolo, no la cantidad de acciones que compró
cuantasTieneDe'' simb usuario = length . filter ((==simb).simboloAccion) $ listaDeTitulos usuario


-- Punto 3

-- 3.1 nuevoPrecioAccion

-- version 1:
nuevoPrecioAccion nuevoPrecio accion = accion { precios = nuevoPrecio : precios accion }

-- version 2:
-- * Esta devuelve los precios actualizados solamente, no la Acción
nuevoPrecioAccion' precio = (precio :) . precios 

-- version 3:
-- * Esta pisa la lista de precios, con lo cual lo que recibe en realidad no es el nuevo precio sino el nuevo histórico de precios
nuevoPrecioAccion'' nuevoHistorico accion = accion { precios = nuevoHistorico } 

-- 3.2 nuevoPrecio

-- version 1:
nuevoPrecio acciones simboloAccion precio =  
    mapCondicional (nuevoPrecioAccion precio) ((== simboloAccion) . simbolo) acciones

-- version 2:
-- * Hace lo mismo que la anterior pero usando una definición local para el "matcheo" de simbolos
-- * Aprovecha la lista de acciones como último parámetro para usar notación point free
nuevoPrecio' simboloABuscar precioNuevo = 
    mapCondicional (nuevoPrecioAccion precioNuevo) condicion
        where condicion accion = simbolo accion == simboloABuscar

-- version 3:
-- * Aprovecha la definición de la función 'encontrar'
-- * Devuelve solo la acción modificada, no la lista
nuevoPrecio'' acciones simboloAccion nuevoPrecio = 
    nuevoPrecioAccion nuevoPrecio . encontrar ((== simboloAccion) . simbolo)  $ acciones


-- 3.3 precioActual
precioActual = head . precios


-- Punto 4: estadoActual

-- version 1:
-- * Soporta que el usuario haya comprado mas de una vez el título a precios distintos
estadoActual listaDeAcciones = 
    sum . map (\titulo -> (precioAccion titulo - precio titulo) * cantidad titulo) . listaDeTitulos 
        where precioAccion titulo = precioActual . encontrar ((== simboloAccion titulo).simbolo) $ listaDeAcciones 

-- version 2:
-- * Hace lo mismo que la anterior pero con 2 definiciones locales en vez de 1 y 1 lambda
estadoActual' usuario = sum . map  diferenciaPrecio
   where diferenciaPrecio accion = (precioActual accion - precio (titulo accion)) * cantidad (titulo accion)
         titulo accion = encontrar (( == simbolo accion) . simboloAccion ) $ listaDeTitulos usuario


-- Punto 5: pagarDividendos
pagarDividendos usuarios dividendos simb = 
    mapCondicional actualizarUsuario accionEncontrada usuarios
        where actualizarUsuario usuario = usuario { efectivo = efectivo usuario + dividendos * cuantasTieneDe simb usuario }
              accionEncontrada usuario = any ((==simb) . simboloAccion) $ listaDeTitulos usuario


-- Punto 6: rescateFinanciero
-- * Dijimos que sonaba a un mapCondicional...


-- Punto 7: venta
-- * Dijimos que una solución donde un usuario puede comprar mas de una vez una acción a precios distintos complica mucho resolver este punto


-- Punto 8:
-- * Se mencionó una referencia a algo visto en clases anteriores (maximoSegún)


-- Punto 9: inferencia de tipos y justificación

-- funcionQueNoDebeSerNombrada :: Ord b => b -> ( a -> Number -> b -> b ) -> [ a ] -> Bool
-- funcionQueNoDebeSerNombrada x y = (>= x) . foldr (flip y 10) x

-- Tipos auxiliares:
-- flip :: ( b -> a -> c -> d ) -> a -> b -> c -> d             (Esta "version" de flip es lo que pasaría si recibe una función de 3 parámetros)
-- foldr :: ( a -> b -> b ) -> b -> [a] -> b