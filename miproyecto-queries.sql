-- CONSULTAS MULTITABLA
-- 1. Obtener nombre de cada equipo, de su presidente y el total de goles
-- anotados por sus jugadores en todos los partidos.
select e.Nombre_equipo, p.Nombre_presi, COALESCE(sum(pa.goles_casa + pa.goles_visitante), 0) as total_goles
from equipo e left join presidente p
    on e.PRESIDENTE_DNI = p.DNI
    left join partido pa
    on e.Id_equipo = pa.EQUIPO_Id_equipo_local or e.Id_equipo = pa.EQUIPO_Id_equipo_visitante
    left join gol g
    on (pa.Id_partido = g.id_partido and
    (g.id_jugador in (select id_jugador
    from jugador j
    where j.EQUIPO_Id_equipo = e.Id_equipo )
    ))
group by e.Nombre_equipo, p.Nombre_presi
order by total_goles desc;

-- 2. Jugadores que han anotado al menos un gol en más de 10 partidos
-- diferentes, con su nombre, posición y total de goles anotados.
select j.Nombre, j.Apellidos, j.Posicion,
  count(distinct g.id_partido) as partidos_con_gol,
  count(g.id_jugador) as total_goles
from jugador j inner join gol g
    on j.id_jugador = g.id_jugador
group by j.Nombre, j.Apellidos, j.Posicion
having count(distinct g.id_partido) > 10
order by total_goles desc;

-- 3. Árbitros y el nº de partidos dirigidos en campos con un nombre específico,
-- junto con el total de goles en esos partidos.
Select a.Nombre_arbitro, COUNT(pa.id_partido) as partidos_dirigidos,
  SUM(COALESCE(pa.goles_casa, 0) + COALESCE(pa.goles_visitante, 0)) as total_goles
from arbitro a inner join partido pa
on a.id_arbitro = pa.ARBITRO_id_arbitro
    inner join campo c
on pa.CAMPO_Id_campo = c.Id_campo
    left join gol g
on pa.id_partido = g.id_partido
where
  c.Nombre_campo = 'Lorène'
group by
  a.Nombre_arbitro
having
  COUNT(pa.id_partido) > 0
order by
  partidos_dirigidos DESC;

-- 4. Equipos con el total de victorias como local,
-- incluyendo sólo aquellos que tengan más de 3.
select e.Nombre_equipo, count(*) as victorias_local
from equipo e inner join partido p
    on e.id_equipo = p.EQUIPO_id_equipo_local
where p.id_partido in (
        select id_partido
        from partido p
        where p.Goles_casa > p.Goles_visitante
)
group by e.Nombre_equipo
having victorias_local > 3
order by victorias_local desc;

-- 5. Campos donde se jugaron partidos con un total de goles
-- superior al promedio general.
select c.Nombre_campo, AVG(p.Goles_casa + p.Goles_visitante) as promedio_goles
from campo c inner join partido p
    on c.id_campo = p.CAMPO_id_campo
group by c.Nombre_campo
having AVG(p.Goles_casa + p.Goles_visitante) > (
        select avg(p.Goles_casa + p.Goles_visitante)
        from partido p
        )
order by promedio_goles desc;


-- VISTAS
-- 1. Muestra el nombre de cada equipo, el nombre de su presidente y
-- el total de goles anotados por sus jugadores en los partidos
create view vista_Equipo_Goles as
select e.Nombre_equipo, p.Nombre_presi,
coalesce(sum(pa.Goles_casa + pa.Goles_visitante), 0) as total_goles
from equipo e left join presidente p
    on e.PRESIDENTE_DNI = p.DNI
left join partido pa
    on e.Id_equipo = pa.EQUIPO_Id_equipo_local
    or e.Id_equipo = pa.EQUIPO_Id_equipo_visitante
    left join gol g
    on (pa.Id_partido = g.id_partido and g.id_jugador in (
  select id_jugador
  from jugador j
  where j.EQUIPO_Id_equipo = e.Id_equipo
))
group by e.Nombre_equipo, p.Nombre_presi;

select * from vista_Equipo_Goles veg order by total_goles;

-- 2. Identifica los campos donde el promedio de goles por partido supera al
-- promedio general de todos los partidos
create view vista_Campos_Promedio_Goles_Superior as
select c.Nombre_campo,
    avg(p.Goles_casa + p.Goles_visitante) as promedio_goles
from campo c inner join partido p
    on c.id_campo = p.CAMPO_id_campo
group by c.Nombre_campo
having avg(p.Goles_casa + p.Goles_visitante) > (
        select avg(p.Goles_casa + p.Goles_visitante)
        from partido p
);

select *
from vista_Campos_Promedio_Goles_Superior vcpgs order by promedio_goles desc;


-- FUNCIONES
-- 1. Calcula el total de goles anotados por los jugadores
-- de un equipo en todos los partidos.
delimiter &&
create function calcularTotalGolesEquipo(id_equipo int)
returns int
deterministic
begin
  declare total int;
  select count(*) into total
  from gol g inner join jugador j
      on g.id_jugador = j.id_jugador
  where j.EQUIPO_Id_equipo = id_equipo;
  return total;
end &&
delimiter ;

select calcularTotalGolesEquipo(2) as total_goles_segundo_equipo;

-- 2. Calcula el promedio de goles por partido en un campo específico.
delimiter &&
create function obtenerPromedioGolesCampo(id_campo int)
returns decimal(5,2)
deterministic
begin
  declare promedio decimal(5,2);
  select avg(p.Goles_casa + p.Goles_visitante) into promedio
  from partido p
  where p.CAMPO_Id_campo = id_campo;
  return promedio;
end &&
delimiter ;

SELECT obtenerPromedioGolesCampo(2) as promedio_goles;



-- PROCEDIMIENTOS
-- 1. Insertar un nuevo jugador en la tabla JUGADOR.
delimiter &&
create procedure InsertarJugadorYAsignarEquipo( in nombre varchar(50),
    in apellidos varchar(50), in fecha_nac date, in posicion varchar(20),
  in id_equipo int
)
begin
  insert into jugador (Nombre, Apellidos, Fecha_nacimiento, Posicion,
  EQUIPO_Id_equipo)
  values (nombre, apellidos, fecha_nac, posicion, id_equipo);
end &&
delimiter ;

call InsertarJugadorYAsignarEquipo('Cristiano', 'Ronaldo', '1982-05-16',
'Delantero', 1);
select * from jugador j where j.EQUIPO_Id_equipo = 1;

-- 2. Verifica si un jugador ha marcado goles. Si no ha marcado,
-- muestra un mensaje “NO HA MARCADO NINGÚN GOL”.
-- Si ha marcado, lista los partidos y los minutos en los que anotó.
delimiter &&
create procedure mostrarGolesJugador(in id_jugador int)
begin
    declare total_goles int;
    select count(*) into total_goles
    from gol g
    where g.id_jugador = id_jugador;
    if total_goles = 0 then
        select 'NO HA MARCADO NINGÚN GOL' as mensaje;
    else
        select g.id_partido, g.Minuto
        from gol g
        where g.id_jugador = id_jugador
        order by g.id_partido , g.Minuto;
    end if;
end &&
delimiter ;

call mostrarGolesJugador(1);
call mostrarGolesJugador(2);

-- 3. Actualiza el aforo de un campo específico. Si el campo no existe o
-- al introducir el aforo es igual o menor que 0 da un error.
delimiter &&
create procedure actualizarAfrocampo(in p_id_campo int, in p_nuevo_aforo int
)
begin
    declare campo_existe int;
    
    select count(*) into campo_existe 
    from campo 
    where id_campo = p_id_campo;
    
    if campo_existe = 1 then
        if p_nuevo_aforo > 0 then
            update campo
            set aforo = p_nuevo_aforo
            where id_campo = p_id_campo;
        else
            signal sqlstate '45000' 
            set message_text = 'el aforo debe ser mayor que 0.';
        end if;
    else
        signal sqlstate '45000' 
        set message_text = 'el campo especificado no existe.';
    end if;
end &&
delimiter ;

-- Consulta error el aforo es 0 o menor:
CALL actualizarAforoCampo(1,0);

-- Consulta error id_campo no existe:
CALL actualizarAforoCampo(550,50000);

CALL actualizarAforoCampo(2, 50000);
select id_campo, aforo from campo where id_campo = 2;


-- TRIGGERS
-- 1. Update. Al insertar un nuevo gol en la tabla GOL, se actualiza
-- automáticamente los goles del partido en la tabla PARTIDO.
delimiter &&
create trigger actualizarGolesPartidoDespuesGol
after insert on gol
for each row
begin
    
  declare equipo_jugador int;
  declare equipo_local int;
  declare equipo_visitante int;
 
  select EQUIPO_Id_equipo into equipo_jugador
  from jugador
  where id_jugador = NEW.id_jugador;
 
  select EQUIPO_Id_equipo_local, EQUIPO_Id_equipo_visitante
  into equipo_local, equipo_visitante
  from partido
  where Id_partido = NEW.id_partido;
 
  if equipo_jugador = equipo_local then
      update partido
      set Goles_casa = Goles_casa + 1
      where Id_partido = NEW.id_partido;
  elseif equipo_jugador = equipo_visitante then
      update partido
      set Goles_visitante = Goles_visitante + 1
      where Id_partido = NEW.id_partido;
  end if;
end &&
delimiter ;

select Goles_casa, Goles_visitante from partido where Id_partido = 10;

insert into gol (id_partido, id_jugador, Minuto)
values (10, 51, 12);

-- 2. Insert. Verifica que el jugador a insertar
-- tenga al menos 16 años, si no cumple esta condición,
-- no lo inserta e inserta un mensaje de error en otra tabla.
create table error_insert (
    mensaje varchar(255),
    fecha_error datetime
);

select * from error_insert;

delimiter &&
create trigger verificarEdadJugadorAntesInsertar
before insert on jugador
for each row
begin
    declare edad int;

    set edad = TIMESTAMPDIFF(YEAR, new.Fecha_nacimiento, CURDATE());

    if edad < 16 then
        insert into error_insert (mensaje, fecha_error)
        values (
            concat('Error: El jugador ', new.Nombre, ' ', new.Apellidos,
            ' tiene ', edad, ' años y no cumple con la edad mínima de 16 años.'),
            now()
        );

        set new.id_jugador = NULL;
       
    end if;
end &&
delimiter ;

insert into jugador (id_jugador, Nombre, Apellidos, Posicion, EQUIPO_Id_equipo, Fecha_nacimiento) 
values (1003, 'Jugador', 'Mayor', 'Delantero', 1, '2006-05-05');

select id_jugador, Nombre, Fecha_nacimiento from jugador where id_jugador = 1003;
select mensaje, fecha_error from error_insert ei;

