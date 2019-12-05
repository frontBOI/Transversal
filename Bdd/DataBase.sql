create table public.t_post
(
    id_post serial  not null constraint t_post_pkey primary key,
    pos_x   integer not null,
    pos_y   integer not null,
    pos_i   integer not null,
    constraint uk_posx_posy unique (pos_x, pos_y)
);


create table public.t_posr
(
    id_posr serial not null constraint t_posr_pkey primary key,
    coord_latitude  double precision not null,
    coord_longitude double precision not null,
    id_post integer not null constraint t_posr_id_post_fkey references public.t_post,
    constraint uk_coordx_coordy unique (coord_latitude, coord_longitude)
);

create table public.t_incendie
(
    id_incendie serial not null constraint t_incendie_pkey primary key,
    id_post integer not null constraint t_incendie_id_post_fkey references public.t_post,
    date_incendie timestamp not null
);


create table public.t_caserne
(
    id_caserne  serial not null constraint t_caserne_pkey primary key,
    nom_caserne varchar(250) not null
);


create table public.t_camion
(
    id_camion serial not null constraint t_camion_pkey primary key,
    immatriculation_camion varchar(15),
    capacite_camion integer not null,
    id_caserne integer constraint t_camion_id_caserne_fkey references public.t_caserne
);

create table public.t_affectation
(
    id_affectation serial  not null constraint t_affectation_pkey primary key,
    id_camion      integer not null constraint t_affectation_id_camion_fkey references public.t_camion,
    id_incendie    integer not null constraint t_affectation_id_incendie_fkey references public.t_incendie
);



create or replace view v_pos(pos_y, pos_x, pos_i) as
SELECT t_post.pos_y,
       t_post.pos_x,
       t_post.pos_i
FROM t_post;


create or replace view v_camion_disponible
            (id_camion, immatriculation_camion, capacite_camion, id_caserne) as
SELECT t_camion.id_camion,
       t_camion.immatriculation_camion,
       t_camion.capacite_camion,
       t_camion.id_caserne       
FROM t_camion
WHERE (NOT (t_camion.id_camion IN (SELECT t_affectation.id_camion
                                   FROM t_affectation)));

create or replace view v_capacite_cumule_camion
            (id_camion, immatriculation_camion, capacite_camion, id_caserne, capacite_cumule) as
SELECT v_camion_disponible.id_camion,
       v_camion_disponible.immatriculation_camion,
       v_camion_disponible.capacite_camion,
       v_camion_disponible.id_caserne,
       sum(v_camion_disponible.capacite_camion)
       OVER (PARTITION BY v_camion_disponible.id_caserne ORDER BY v_camion_disponible.capacite_camion DESC) AS capacite_cumule
FROM v_camion_disponible;


create or replace view v_detail_trigger
            (event_object_table, trigger_name, event_manipulation, action_statement, action_timing) as
SELECT triggers.event_object_table,
       triggers.trigger_name,
       triggers.event_manipulation,
       triggers.action_statement,
       triggers.action_timing
FROM information_schema.triggers
ORDER BY triggers.event_object_table, triggers.event_manipulation;

create or replace function ps_emergency_manager_incendie() returns trigger language plpgsql
as
DECLARE
       Incendie_intensite INTEGER;
       Capacite_gere integer;
   BEGIN
      select pos_i into Incendie_intensite from t_post where t_post.id_post = new.id_post;

      insert into t_affectation(id_camion, id_incendie)
      select id_camion ,new.id_incendie from v_capacite_cumule_camion where capacite_cumule <= Incendie_intensite;

      select sum(capacite_camion) into Capacite_gere from t_affectation join t_camion on t_affectation.id_camion = t_camion.id_camion where id_incendie=Incendie_intensite;

      if Capacite_gere<Incendie_intensite then



      end if;

    return new;
END

create function ps_emergency_manager_post() returns trigger language plpgsql
as
DECLARE
       NB_Ligne INTEGER := 0;
       ID_INCENDI INTEGER;
   BEGIN
       SELECT count(*) into NB_Ligne from t_incendie where t_incendie.id_post=new.id_post;
       if NEW.pos_i <> 0 and NB_Ligne = 0 then
                insert into t_incendie(id_post,date_incendie) values (new.id_post,now());
        end if;
       if NEW.pos_i = 0 then
           select id_incendie into ID_INCENDI from t_incendie where t_incendie.id_post=new.id_post ;
           delete from t_affectation where id_incendie = ID_INCENDI;
           delete  from t_incendie where id_incendie=ID_INCENDI;
       end if;
       return new;
END

create function ps_tg_insert_t_post() returns trigger language plpgsql
as
BEGIN
       UPDATE t_post set pos_i=new.pos_i where pos_x=new.pos_x and pos_y=new.pos_y ;
      RETURN NEW;
END;

create trigger tg_insert_t_post after insert on v_pos for each row
execute procedure ps_tg_insert_t_post();

create trigger tg_emergency_manager after update on t_post for each row
execute procedure ps_emergency_manager_post();

create trigger tg_emergency_manager after insert on t_incendie for each row
execute procedure ps_emergency_manager_incendie();









