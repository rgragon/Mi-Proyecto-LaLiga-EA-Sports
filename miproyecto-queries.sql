-- CONSULTAS MULTITABLA
-- 1.
select e.nombre_equipo, p.nombre_presi, coalesce(sum(pa.goles_casa + pa.goles_visitante), 0) as total_goles
from equipo e left join presidente p
    on e.presidente_dni = p.dni
    left join partido pa
    on e.id_equipo = pa.equipo_id_equipo_local or e.id_equipo = pa.equipo_id_equipo_visitante
    left join gol g
    on (pa.id_partido = g.id_partido and
    (g.id_jugador in (select id_jugador
    from jugador j
    where j.equipo_id_equipo = e.id_equipo )
    ))
group by e.nombre_equipo, p.nombre_presi
order by total_goles desc;

-- 2.
select j.nombre, j.apellidos, j.posicion,
  count(distinct g.id_partido) as partidos_con_gol,
  count(g.id_jugador) as total_goles
from jugador j inner join gol g
    on j.id_jugador = g.id_jugador
group by j.nombre, j.apellidos, j.posicion
having count(distinct g.id_partido) > 10
order by total_goles desc;

-- 3.
select a.nombre_arbitro, count(pa.id_partido) as partidos_dirigidos,
  sum(coalesce(pa.goles_casa, 0) + coalesce(pa.goles_visitante, 0)) as total_goles
from arbitro a inner join partido pa
on a.id_arbitro = pa.arbitro_id_arbitro
    inner join campo c
on pa.campo_id_campo = c.id_campo
    left join gol g
on pa.id_partido = g.id_partido
where
  c.nombre_campo = 'lorène'
group by
  a.nombre_arbitro
having
  count(pa.id_partido) > 0
order by
  partidos_dirigidos desc;
 
-- 4.
select e.nombre_equipo, count(*) as victorias_local
from equipo e inner join partido p
    on e.id_equipo = p.equipo_id_equipo_local
where p.id_partido in (
        select id_partido
        from partido p
        where p.goles_casa > p.goles_visitante
)
group by e.nombre_equipo
having victorias_local > 3
order by victorias_local desc;

-- 5.
select c.nombre_campo, avg(p.goles_casa + p.goles_visitante) as promedio_goles
from campo c inner join partido p
    on c.id_campo = p.campo_id_campo
group by c.nombre_campo
having avg(p.goles_casa + p.goles_visitante) > (
        select avg(p.goles_casa + p.goles_visitante)
        from partido p
        )
order by promedio_goles desc;

____________________________________________________________________________________________________________
-- VISTAS
-- 1.
create view vista_equipo_goles as
select e.nombre_equipo, p.nombre_presi,
coalesce(sum(pa.goles_casa + pa.goles_visitante), 0) as total_goles
from equipo e left join presidente p
    on e.presidente_dni = p.dni
left join partido pa
    on e.id_equipo = pa.equipo_id_equipo_local
    or e.id_equipo = pa.equipo_id_equipo_visitante
    left join gol g
    on (pa.id_partido = g.id_partido and g.id_jugador in (
  select id_jugador
  from jugador j
  where j.equipo_id_equipo = e.id_equipo
))
group by e.nombre_equipo, p.nombre_presi;

-- 2.
create view vista_campos_promedio_goles_superior as
select c.nombre_campo,
    avg(p.goles_casa + p.goles_visitante) as promedio_goles
from campo c inner join partido p
    on c.id_campo = p.campo_id_campo
group by c.nombre_campo
having avg(p.goles_casa + p.goles_visitante) > (
        select avg(p.goles_casa + p.goles_visitante)
        from partido p
);


____________________________________________________________________________________________________________
-- FUNCIONES
-- 1.
delimiter &&
create function calcularTotalGolesEquipo(id_equipo int)
returns int
deterministic
begin
  declare total int;
  select count(*) into total
  from gol g inner join jugador j
  	on g.id_jugador = j.id_jugador
  where j.equipo_id_equipo = id_equipo;
  return total;
end &&
delimiter ;

-- 2.
delimiter &&
create function obtenerPromedioGolescampo(id_campo int)
returns decimal(5,2)
deterministic
begin
  declare promedio decimal(5,2);
  select avg(p.goles_casa + p.goles_visitante) into promedio
  from partido p
  where p.campo_id_campo = id_campo;
  return promedio;
end &&
delimiter ;


____________________________________________________________________________________________________________
-- PROCEDIMIENTOS
-- 1.
delimiter &&
create procedure insertarJugadorYAsignarEquipo( in nombre varchar(50),
	in apellidos varchar(50), in posicion varchar(20),
  in id_equipo int
)
begin
  insert into jugador (nombre, apellidos, posicion, equipo_id_equipo)
  values (nombre, apellidos, posicion, id_equipo);
end &&
delimiter ;

-- 2.
delimiter &&
create procedure mostrarGolesJugador(in id_jugador int)
begin
	declare total_goles int;
	select count(*) into total_goles
	from gol g
	where g.id_jugador = id_jugador;
	if total_goles = 0 then
		select 'no ha marcado ningún gol' as mensaje;
	else
		select g.id_partido, g.minuto
		from gol g
		where g.id_jugador = id_jugador
		order by g.id_partido , g.minuto;
	end if;
end &&
delimiter ;

-- 3.
delimiter &&
create procedure actualizarAforoCampo(in p_id_campo int, in p_nuevo_aforo int
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


____________________________________________________________________________________________________________
-- TRIGGERS
-- 1.
delimiter &&
create trigger actualizarGolesPartidoDespuesgol
after insert on gol
for each row
begin
	
  declare equipo_jugador int;
  declare equipo_local int;
  declare equipo_visitante int;
 
  select equipo_id_equipo into equipo_jugador
  from jugador
  where id_jugador = new.id_jugador;
 
  select equipo_id_equipo_local, equipo_id_equipo_visitante
  into equipo_local, equipo_visitante
  from partido
  where id_partido = new.id_partido;
 
  if equipo_jugador = equipo_local then
      update partido
      set goles_casa = goles_casa + 1
      where id_partido = new.id_partido;
  elseif equipo_jugador = equipo_visitante then
      update partido
      set goles_visitante = goles_visitante + 1
      where id_partido = new.id_partido;
  end if;
end &&
delimiter ;

select goles_casa, goles_visitante from partido where id_partido = 10;

insert into gol (id_partido, id_jugador, minuto)
values (10, 51, 12);

-- 2.
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

    set edad = timestampdiff(year, new.fecha_nacimiento, curdate());

    if edad < 16 then
        insert into error_insert (mensaje, fecha_error)
        values (
            concat('error: el jugador ', new.nombre, ' ', new.apellidos,
            ' tiene ', edad, ' años y no cumple con la edad mínima de 16 años.'),
            now()
        );

        set new.id_jugador = null;
       
    end if;
end &&
delimiter ;

insert into jugador (id_jugador, nombre, apellidos, posicion, equipo_id_equipo, fecha_nacimiento) 
values (1003, 'jugador', 'mayor', 'delantero', 1, '2006-05-05');

select id_jugador, nombre, fecha_nacimiento from jugador where id_jugador = 1003;
select mensaje, fecha_error from error_insert ei;