PGDMP                         y        	   urbanonto    12.1    13.1 �               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    37727 	   urbanonto    DATABASE     m   CREATE DATABASE urbanonto WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_United States.1252';
    DROP DATABASE urbanonto;
                postgres    false            	            2615    45859    ontology    SCHEMA        CREATE SCHEMA ontology;
    DROP SCHEMA ontology;
                postgres    false                        2615    45860    ontology_sources    SCHEMA         CREATE SCHEMA ontology_sources;
    DROP SCHEMA ontology_sources;
                postgres    false                        3079    46424    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false                       0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    2                        1255    45862 
   lastdate()    FUNCTION     �   CREATE FUNCTION ontology.lastdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN    
   
  		NEW.last_date := current_timestamp;
    
        RETURN NEW;
 END;
$$;
 #   DROP FUNCTION ontology.lastdate();
       ontology          postgres    false    9            �            1259    45863 *   topographic_object_function_manifestations    TABLE       CREATE TABLE ontology.topographic_object_function_manifestations (
    identifier integer NOT NULL,
    topographic_object_identifier integer NOT NULL,
    start_at date,
    end_at date,
    function_identifier integer NOT NULL,
    historical_evidence_identifier integer NOT NULL
);
 @   DROP TABLE ontology.topographic_object_function_manifestations;
       ontology         heap    postgres    false    9            �           1255    53437 8   topographic_object_function_manifestations_filled_func()    FUNCTION     �  CREATE FUNCTION ontology.topographic_object_function_manifestations_filled_func() RETURNS SETOF ontology.topographic_object_function_manifestations
    LANGUAGE plpgsql
    AS $$

DECLARE
 toi integer;
 i integer;
 filled_count integer;

begin
	EXECUTE 'SELECT max(identifier) FROM ontology.topographic_object_function_manifestations' INTO i;
	RETURN QUERY SELECT * FROM ontology.topographic_object_function_manifestations;
	-- GET DIAGNOSTICS i = ROW_COUNT;
	FOR toi in
	 SELECT DISTINCT(N.topographic_object_identifier) FROM ontology.topographic_object_function_manifestations N ORDER BY N.topographic_object_identifier
	LOOP
	 RETURN QUERY SELECT d.identifier,d.topographic_object_identifier,d.start_at,d.end_at,d.function_identifier,d.historical_source_identifier
	 FROM (
      SELECT	(i + (row_number() over ())::integer) AS identifier,
				t.topographic_object_identifier,
				t.end_at AS start_at,
				LEAD(t.start_at) OVER (partition by t.topographic_object_identifier = toi ORDER BY t.start_at) AS end_at,
				t.function_identifier,
				NULL::integer AS historical_source_identifier,
				LEAD(t.start_at) OVER (partition by t.topographic_object_identifier = toi ORDER BY t.start_at) - t.end_at AS diff
	  FROM ontology.topographic_object_function_manifestations t
	  WHERE t.topographic_object_identifier = toi ORDER BY t.start_at) d
	 WHERE d.diff > 0;
	GET DIAGNOSTICS filled_count = ROW_COUNT;
	-- raise notice 'i=%',filled_count;
	i := i + filled_count;
	END LOOP;
	RETURN;
END
$$;
 Q   DROP FUNCTION ontology.topographic_object_function_manifestations_filled_func();
       ontology          postgres    false    205    9            �            1259    45867 *   topographic_object_location_manifestations    TABLE     H  CREATE TABLE ontology.topographic_object_location_manifestations (
    identifier integer NOT NULL,
    topographic_object_identifier integer NOT NULL,
    start_at date,
    end_at date,
    location_identifier integer NOT NULL,
    historical_evidence_identifier integer NOT NULL,
    location_link_type_identifier integer
);
 @   DROP TABLE ontology.topographic_object_location_manifestations;
       ontology         heap    postgres    false    9            �           1255    45870 8   topographic_object_location_manifestations_filled_func()    FUNCTION     
  CREATE FUNCTION ontology.topographic_object_location_manifestations_filled_func() RETURNS SETOF ontology.topographic_object_location_manifestations
    LANGUAGE plpgsql
    AS $$
/* Generowanie manifestacji o charakterze ciągłym
Dane wejściowe (ontology.topographic_object_location_manifestations)
Dane wyjściowe: tabela o strukturze zgodnej z ontology.topographic_object_location_manifestations
"dziura czasowa" jest wypełniana całkowicie tylko jedną manifestacją o wartości odpowiadającej poprzedniej manifestacji
      NEXT(max(identifiers)), KOPIA(before), ends_at(before), start_at(next), KOPIA(before), historical_source_identifiers=NULL, KOPIA(before)
*/

DECLARE
 toi integer;
 i integer;
 filled_count integer;

begin
	EXECUTE 'SELECT max(identifier) FROM ontology.topographic_object_location_manifestations' INTO i;
	RETURN QUERY SELECT * FROM ontology.topographic_object_location_manifestations;
	-- GET DIAGNOSTICS i = ROW_COUNT;
	FOR toi in
	 SELECT DISTINCT(N.topographic_object_identifier) FROM ontology.topographic_object_location_manifestations N ORDER BY N.topographic_object_identifier
	LOOP
	 RETURN QUERY SELECT d.identifier,d.topographic_object_identifier,d.start_at,d.end_at,d.location_identifier,d.historical_source_identifier,d.location_link_type_identifier
	 FROM (
      SELECT	(i + (row_number() over ())::integer) AS identifier,
				t.topographic_object_identifier,
				t.end_at AS start_at,
				LEAD(t.start_at) OVER (partition by t.topographic_object_identifier = toi ORDER BY t.start_at) AS end_at,
				t.location_identifier,
				NULL::integer AS historical_source_identifier,
				t.location_link_type_identifier,
				LEAD(t.start_at) OVER (partition by t.topographic_object_identifier = toi ORDER BY t.start_at) - t.end_at AS diff
	  FROM ontology.topographic_object_location_manifestations t
	  WHERE t.topographic_object_identifier = toi ORDER BY t.start_at) d
	 WHERE d.diff > 0;
	GET DIAGNOSTICS filled_count = ROW_COUNT;
	-- raise notice 'i=%',filled_count;
	i := i + filled_count;
	END LOOP;
	RETURN;
END
$$;
 Q   DROP FUNCTION ontology.topographic_object_location_manifestations_filled_func();
       ontology          postgres    false    206    9            �            1259    53381 !   topographic_object_manifestations    TABLE     �   CREATE TABLE ontology.topographic_object_manifestations (
    identifier integer,
    topographic_object_identifier integer,
    start_at date,
    end_at date,
    function text,
    the_geom public.geometry,
    name text,
    type text
);
 7   DROP TABLE ontology.topographic_object_manifestations;
       ontology         heap    postgres    false    2    2    2    2    2    2    2    2    9            �           1255    53390 (   topographic_object_manifestations_func()    FUNCTION     �  CREATE FUNCTION ontology.topographic_object_manifestations_func() RETURNS SETOF ontology.topographic_object_manifestations
    LANGUAGE plpgsql
    AS $$
    DECLARE 
     toi integer;
     i integer;
     filled_count integer;
    
	BEGIN
	 i = 0;
	 FOR toi in
	  SELECT DISTINCT(N.topographic_object_identifier) FROM ontology.topographic_object_function_manifestations N ORDER BY N.topographic_object_identifier
	 LOOP
	  RETURN QUERY

SELECT
 (i + (ROW_NUMBER() OVER ())::integer)  AS identifier,
 at.topographic_object_identifier      AS topographic_object_identifier,
 at.start_at                           AS start_at,
 at.end_at                             AS end_at,
 -- fm.identifier                      AS function_manifestation_identifier,
 f.name                               AS function,
 -- f.iris                              AS function_iris,
 -- lm.identifier                      AS location_manifestation_identifier,
 l.the_geom                             AS the_geom,
 -- nm.identifier                      AS name_manifestation_identifier,
 nm.name                               AS name,
 -- tm.identifier                      AS type_manifestation_identifier,
 t.name                                AS type
 -- t.iris                              AS type_iris
FROM
 (
  SELECT * FROM
  (
   SELECT toi AS topographic_object_identifier,d.d AS start_at,LEAD(d.d) OVER (ORDER BY d) AS end_at FROM
   (
    SELECT distinct(unnest(array[S.start_at,S.end_at])) AS d FROM ontology.topographic_object_function_manifestations_filled S WHERE S.topographic_object_identifier = toi
    UNION
    SELECT distinct(unnest(array[S.start_at,S.end_at])) AS d FROM ontology.topographic_object_location_manifestations_filled S WHERE S.topographic_object_identifier = toi
    UNION
    SELECT distinct(unnest(array[S.start_at,S.end_at])) AS d FROM ontology.topographic_object_name_manifestations_filled     S WHERE S.topographic_object_identifier = toi
    UNION
    SELECT distinct(unnest(array[S.start_at,S.end_at])) AS d FROM ontology.topographic_object_type_manifestations_filled     S WHERE S.topographic_object_identifier = toi
   ) d
   ORDER BY d.d
  ) d
  WHERE (d.start_at IS NOT NULL) OR (d.end_at IS NOT NULL)
 ) at
--      function
LEFT JOIN ontology.topographic_object_function_manifestations_filled    fm ON
(
 (at.topographic_object_identifier = fm.topographic_object_identifier)
 AND
 (
  (COALESCE(at.start_at,'1000-01-01'::date),COALESCE(at.end_at,NOW()::date))
   OVERLAPS
  (COALESCE(fm.start_at,'1000-01-01'::date),COALESCE(fm.end_at,NOW()::date))
 )
) LEFT JOIN ontology.functions                                          f ON
(
 fm.function_identifier = f.identifier
)
--      location
LEFT JOIN ontology.topographic_object_location_manifestations_filled    lm ON
(
 (at.topographic_object_identifier = lm.topographic_object_identifier)
 AND
 (
  (COALESCE(at.start_at,'1000-01-01'::date),COALESCE(at.end_at,NOW()::date))
   OVERLAPS
  (COALESCE(lm.start_at,'1000-01-01'::date),COALESCE(lm.end_at,NOW()::date))
 )
) LEFT JOIN ontology.locations                                          l ON
(
 lm.location_identifier = l.identifier
)
--      name
LEFT JOIN ontology.topographic_object_name_manifestations_filled        nm ON
(
 (at.topographic_object_identifier = nm.topographic_object_identifier)
 AND
 (
  (COALESCE(at.start_at,'1000-01-01'::date),COALESCE(at.end_at,NOW()::date))
   OVERLAPS
  (COALESCE(nm.start_at,'1000-01-01'::date),COALESCE(nm.end_at,NOW()::date))
 )
)
--      type
LEFT JOIN ontology.topographic_object_type_manifestations_filled        tm ON
(
 (at.topographic_object_identifier = tm.topographic_object_identifier)
 AND
 (
  (COALESCE(at.start_at,'1000-01-01'::date),COALESCE(at.end_at,NOW()::date))
   OVERLAPS
  (COALESCE(tm.start_at,'1000-01-01'::date),COALESCE(tm.end_at,NOW()::date))
 )
) LEFT JOIN ontology.topographic_types                                  t ON
(
 tm.type_identifier = t.identifier
)
WHERE lm.identifier IS NOT NULL AND (nm.identifier IS NOT NULL or tm.identifier IS NOT NULL);

     GET DIAGNOSTICS filled_count = ROW_COUNT;
     i := i + filled_count;
     END LOOP;
	RETURN;
	END;
$$;
 A   DROP FUNCTION ontology.topographic_object_manifestations_func();
       ontology          postgres    false    250    9            �            1259    45871 &   topographic_object_name_manifestations    TABLE     �  CREATE TABLE ontology.topographic_object_name_manifestations (
    identifier integer NOT NULL,
    topographic_object_identifier integer NOT NULL,
    start_at date,
    end_at date,
    name text NOT NULL,
    historical_evidence_identifier integer NOT NULL,
    name_link_type_identifier integer NOT NULL,
    CONSTRAINT topographic_object_name_manifestations_check CHECK ((NOT ((start_at IS NULL) AND (end_at IS NULL))))
);
 <   DROP TABLE ontology.topographic_object_name_manifestations;
       ontology         heap    postgres    false    9            �           1255    45878 4   topographic_object_name_manifestations_filled_func()    FUNCTION     �  CREATE FUNCTION ontology.topographic_object_name_manifestations_filled_func() RETURNS SETOF ontology.topographic_object_name_manifestations
    LANGUAGE plpgsql
    AS $$
/* Generowanie manifestacji o charakterze ciągłym
Dane wejściowe (ontology.topographic_object_name_manifestations)
Dane wyjściowe: tabela o strukturze zgodnej z ontology.topographic_object_name_manifestations
"dziura czasowa" jest wypełniana całkowicie tylko jedną manifestacją o wartości odpowiadającej poprzedniej manifestacji
      NEXT(max(identifiers)), KOPIA(before), ends_at(before), start_at(next), KOPIA(before), historical_source_identifiers=NULL, KOPIA(before)
*/

DECLARE
 toi integer;
 i integer;
 filled_count integer;

begin
	EXECUTE 'SELECT max(identifier) FROM ontology.topographic_object_name_manifestations' INTO i;
	RETURN QUERY SELECT * FROM ontology.topographic_object_name_manifestations;
	-- GET DIAGNOSTICS i = ROW_COUNT;
	FOR toi in
	 SELECT DISTINCT(N.topographic_object_identifier) FROM ontology.topographic_object_name_manifestations N ORDER BY N.topographic_object_identifier
	LOOP
	 RETURN QUERY SELECT d.identifier,d.topographic_object_identifier,d.start_at,d.end_at,d.name,d.historical_source_identifier,d.name_link_type_identifier
	 FROM (
      SELECT	(i + (row_number() over ())::integer) AS identifier,
				t.topographic_object_identifier,
				t.end_at AS start_at,
				LEAD(t.start_at) OVER (partition by t.topographic_object_identifier = toi ORDER BY t.start_at) AS end_at,
				t."name",
				NULL::integer AS historical_source_identifier,
				t.name_link_type_identifier,
				LEAD(t.start_at) OVER (partition by t.topographic_object_identifier = toi ORDER BY t.start_at) - t.end_at AS diff
	  FROM ontology.topographic_object_name_manifestations t
	  WHERE t.topographic_object_identifier = toi ORDER BY t.start_at) d
	 WHERE d.diff > 0;
	GET DIAGNOSTICS filled_count = ROW_COUNT;
	-- raise notice 'i=%',filled_count;
	i := i + filled_count;
	END LOOP;
	RETURN;
END
$$;
 M   DROP FUNCTION ontology.topographic_object_name_manifestations_filled_func();
       ontology          postgres    false    9    207            �            1259    45879 &   topographic_object_type_manifestations    TABLE       CREATE TABLE ontology.topographic_object_type_manifestations (
    identifier integer NOT NULL,
    topographic_object_identifier integer NOT NULL,
    start_at date,
    end_at date,
    type_identifier integer NOT NULL,
    historical_evidence_identifier integer NOT NULL
);
 <   DROP TABLE ontology.topographic_object_type_manifestations;
       ontology         heap    postgres    false    9            �           1255    45882 4   topographic_object_type_manifestations_filled_func()    FUNCTION     �  CREATE FUNCTION ontology.topographic_object_type_manifestations_filled_func() RETURNS SETOF ontology.topographic_object_type_manifestations
    LANGUAGE plpgsql
    AS $$

DECLARE
 toi integer;
 i integer;
 filled_count integer;

begin
	EXECUTE 'SELECT max(identifier) FROM ontology.topographic_object_type_manifestations' INTO i;
	RETURN QUERY SELECT * FROM ontology.topographic_object_type_manifestations;
	-- GET DIAGNOSTICS i = ROW_COUNT;
	FOR toi in
	 SELECT DISTINCT(N.topographic_object_identifier) FROM ontology.topographic_object_type_manifestations N ORDER BY N.topographic_object_identifier
	LOOP
	 RETURN QUERY SELECT d.identifier,d.topographic_object_identifier,d.start_at,d.end_at,d.type_identifier,d.historical_source_identifier
	 FROM (
      SELECT	(i + (row_number() over ())::integer) AS identifier,
				t.topographic_object_identifier,
				t.end_at AS start_at,
				LEAD(t.start_at) OVER (partition by t.topographic_object_identifier = toi ORDER BY t.start_at) AS end_at,
				t.type_identifier,
				NULL::integer AS historical_source_identifier,
				LEAD(t.start_at) OVER (partition by t.topographic_object_identifier = toi ORDER BY t.start_at) - t.end_at AS diff
	  FROM ontology.topographic_object_type_manifestations t
	  WHERE t.topographic_object_identifier = toi ORDER BY t.start_at) d
	 WHERE d.diff > 0;
	GET DIAGNOSTICS filled_count = ROW_COUNT;
	-- raise notice 'i=%',filled_count;
	i := i + filled_count;
	END LOOP;
	RETURN;
END
$$;
 M   DROP FUNCTION ontology.topographic_object_type_manifestations_filled_func();
       ontology          postgres    false    9    208            �            1259    45883 	   functions    TABLE     t   CREATE TABLE ontology.functions (
    identifier integer NOT NULL,
    iri text NOT NULL,
    name text NOT NULL
);
    DROP TABLE ontology.functions;
       ontology         heap    postgres    false    9                       0    0    TABLE functions    COMMENT     i   COMMENT ON TABLE ontology.functions IS 'The contents of this table will be imported from the ontology.';
          ontology          postgres    false    209                       0    0    COLUMN functions.iri    COMMENT     �   COMMENT ON COLUMN ontology.functions.iri IS 'This is to store internationalized resource identifiers - see: https://tools.ietf.org/html/rfc3987.';
          ontology          postgres    false    209            �            1259    53622 )   geonode_topographic_object_manifestations    MATERIALIZED VIEW     �  CREATE MATERIALIZED VIEW ontology.geonode_topographic_object_manifestations AS
 SELECT topographic_object_manifestations_func.identifier,
    topographic_object_manifestations_func.topographic_object_identifier,
    topographic_object_manifestations_func.start_at,
    topographic_object_manifestations_func.end_at,
    topographic_object_manifestations_func.function,
    topographic_object_manifestations_func.the_geom,
    topographic_object_manifestations_func.name,
    topographic_object_manifestations_func.type
   FROM ontology.topographic_object_manifestations_func() topographic_object_manifestations_func(identifier, topographic_object_identifier, start_at, end_at, function, the_geom, name, type)
  WITH NO DATA;
 K   DROP MATERIALIZED VIEW ontology.geonode_topographic_object_manifestations;
       ontology         heap    postgres    false    970    9    2    2    2    2    2    2    2    2            �            1259    45895    gt_pk_metadata    TABLE     �  CREATE TABLE ontology.gt_pk_metadata (
    table_schema character varying(32) NOT NULL,
    table_name character varying(32) NOT NULL,
    pk_column character varying(32) NOT NULL,
    pk_column_idx integer,
    pk_policy character varying(32),
    pk_sequence character varying(64),
    CONSTRAINT gt_pk_metadata_pk_policy_check CHECK (((pk_policy)::text = ANY (ARRAY[('sequence'::character varying)::text, ('assigned'::character varying)::text, ('autogenerated'::character varying)::text])))
);
 $   DROP TABLE ontology.gt_pk_metadata;
       ontology         heap    postgres    false    9            �            1259    45899    historical_evidences    TABLE     �   CREATE TABLE ontology.historical_evidences (
    identifier integer NOT NULL,
    page_from text,
    page_to text,
    publication_identifier text NOT NULL
);
 *   DROP TABLE ontology.historical_evidences;
       ontology         heap    postgres    false    9            �            1259    45905    location_datasets    TABLE     e   CREATE TABLE ontology.location_datasets (
    identifier integer NOT NULL,
    name text NOT NULL
);
 '   DROP TABLE ontology.location_datasets;
       ontology         heap    postgres    false    9                       0    0    TABLE location_datasets    COMMENT     w   COMMENT ON TABLE ontology.location_datasets IS 'This table is to register all sources for geographic reference data.';
          ontology          postgres    false    212            �            1259    45911    location_link_types    TABLE     �   CREATE TABLE ontology.location_link_types (
    identifier integer NOT NULL,
    name text NOT NULL,
    postgis_function text
);
 )   DROP TABLE ontology.location_link_types;
       ontology         heap    postgres    false    9            �            1259    47446 	   locations    TABLE     �   CREATE TABLE ontology.locations (
    identifier integer NOT NULL,
    the_geom public.geometry NOT NULL,
    name text,
    location_dataset_identifer integer
);
    DROP TABLE ontology.locations;
       ontology         heap    postgres    false    2    2    2    2    2    2    2    2    9            �            1259    45917    name_link_types    TABLE     c   CREATE TABLE ontology.name_link_types (
    identifier integer NOT NULL,
    name text NOT NULL
);
 %   DROP TABLE ontology.name_link_types;
       ontology         heap    postgres    false    9            �            1259    45923 #   overlapping_function_manifestations    VIEW     �   CREATE VIEW ontology.overlapping_function_manifestations AS
 SELECT topographic_object_function_manifestations.topographic_object_identifier AS topographic_object_identifiers
   FROM ontology.topographic_object_function_manifestations;
 8   DROP VIEW ontology.overlapping_function_manifestations;
       ontology          postgres    false    205    9            �            1259    45927    publication_sources    TABLE     s   CREATE TABLE ontology.publication_sources (
    identifier text NOT NULL,
    bibliographic_datum text NOT NULL
);
 )   DROP TABLE ontology.publication_sources;
       ontology         heap    postgres    false    9            �            1259    53446 1   topographic_object_function_manifestations_filled    MATERIALIZED VIEW     1  CREATE MATERIALIZED VIEW ontology.topographic_object_function_manifestations_filled AS
 SELECT topographic_object_function_manifestations_filled_func.identifier,
    topographic_object_function_manifestations_filled_func.topographic_object_identifier,
    topographic_object_function_manifestations_filled_func.start_at,
    topographic_object_function_manifestations_filled_func.end_at,
    topographic_object_function_manifestations_filled_func.function_identifier,
    topographic_object_function_manifestations_filled_func.historical_evidence_identifier
   FROM ontology.topographic_object_function_manifestations_filled_func() topographic_object_function_manifestations_filled_func(identifier, topographic_object_identifier, start_at, end_at, function_identifier, historical_evidence_identifier)
  WITH NO DATA;
 S   DROP MATERIALIZED VIEW ontology.topographic_object_function_manifestations_filled;
       ontology         heap    postgres    false    968    9            �            1259    53453 1   topographic_object_location_manifestations_filled    MATERIALIZED VIEW     �  CREATE MATERIALIZED VIEW ontology.topographic_object_location_manifestations_filled AS
 SELECT topographic_object_location_manifestations_filled_func.identifier,
    topographic_object_location_manifestations_filled_func.topographic_object_identifier,
    topographic_object_location_manifestations_filled_func.start_at,
    topographic_object_location_manifestations_filled_func.end_at,
    topographic_object_location_manifestations_filled_func.location_identifier,
    topographic_object_location_manifestations_filled_func.historical_evidence_identifier,
    topographic_object_location_manifestations_filled_func.location_link_type_identifier
   FROM ontology.topographic_object_location_manifestations_filled_func() topographic_object_location_manifestations_filled_func(identifier, topographic_object_identifier, start_at, end_at, location_identifier, historical_evidence_identifier, location_link_type_identifier)
  WITH NO DATA;
 S   DROP MATERIALIZED VIEW ontology.topographic_object_location_manifestations_filled;
       ontology         heap    postgres    false    967    9            �            1259    45941 3   topographic_object_mereological_link_manifestations    TABLE       CREATE TABLE ontology.topographic_object_mereological_link_manifestations (
    identifier integer NOT NULL,
    start_at date,
    end_at date,
    whole_identifier integer NOT NULL,
    part_identifier integer NOT NULL,
    historical_evidence_identifier integer NOT NULL
);
 I   DROP TABLE ontology.topographic_object_mereological_link_manifestations;
       ontology         heap    postgres    false    9            �            1259    53457 -   topographic_object_name_manifestations_filled    MATERIALIZED VIEW     \  CREATE MATERIALIZED VIEW ontology.topographic_object_name_manifestations_filled AS
 SELECT topographic_object_name_manifestations_filled_func.identifier,
    topographic_object_name_manifestations_filled_func.topographic_object_identifier,
    topographic_object_name_manifestations_filled_func.start_at,
    topographic_object_name_manifestations_filled_func.end_at,
    topographic_object_name_manifestations_filled_func.name,
    topographic_object_name_manifestations_filled_func.historical_evidence_identifier,
    topographic_object_name_manifestations_filled_func.name_link_type_identifier
   FROM ontology.topographic_object_name_manifestations_filled_func() topographic_object_name_manifestations_filled_func(identifier, topographic_object_identifier, start_at, end_at, name, historical_evidence_identifier, name_link_type_identifier)
  WITH NO DATA;
 O   DROP MATERIALIZED VIEW ontology.topographic_object_name_manifestations_filled;
       ontology         heap    postgres    false    969    9            �            1259    45951    topographic_object_provenances    TABLE     �   CREATE TABLE ontology.topographic_object_provenances (
    identifier integer NOT NULL,
    ancestor_identifier integer NOT NULL,
    predecessor_identifier integer NOT NULL,
    historical_evidence_identifier integer NOT NULL
);
 4   DROP TABLE ontology.topographic_object_provenances;
       ontology         heap    postgres    false    9            �            1259    53464 -   topographic_object_type_manifestations_filled    MATERIALIZED VIEW       CREATE MATERIALIZED VIEW ontology.topographic_object_type_manifestations_filled AS
 SELECT topographic_object_type_manifestations_filled_func.identifier,
    topographic_object_type_manifestations_filled_func.topographic_object_identifier,
    topographic_object_type_manifestations_filled_func.start_at,
    topographic_object_type_manifestations_filled_func.end_at,
    topographic_object_type_manifestations_filled_func.type_identifier,
    topographic_object_type_manifestations_filled_func.historical_evidence_identifier
   FROM ontology.topographic_object_type_manifestations_filled_func() topographic_object_type_manifestations_filled_func(identifier, topographic_object_identifier, start_at, end_at, type_identifier, historical_evidence_identifier)
  WITH NO DATA;
 O   DROP MATERIALIZED VIEW ontology.topographic_object_type_manifestations_filled;
       ontology         heap    postgres    false    966    9            �            1259    45958    topographic_objects    TABLE     f   CREATE TABLE ontology.topographic_objects (
    identifier integer NOT NULL,
    default_name text
);
 )   DROP TABLE ontology.topographic_objects;
       ontology         heap    postgres    false    9            �            1259    45964    topographic_types    TABLE     |   CREATE TABLE ontology.topographic_types (
    identifier integer NOT NULL,
    iri text NOT NULL,
    name text NOT NULL
);
 '   DROP TABLE ontology.topographic_types;
       ontology         heap    postgres    false    9                       0    0    TABLE topographic_types    COMMENT     q   COMMENT ON TABLE ontology.topographic_types IS 'The contents of this table will be imported from the ontology.';
          ontology          postgres    false    220                       0    0    COLUMN topographic_types.iri    COMMENT     �   COMMENT ON COLUMN ontology.topographic_types.iri IS 'This is to store internationalized resource identifiers - see: https://tools.ietf.org/html/rfc3987.';
          ontology          postgres    false    220            �            1259    45970    date_mappings    TABLE     u   CREATE TABLE ontology_sources.date_mappings (
    imprecise_date text NOT NULL,
    precise_date integer NOT NULL
);
 +   DROP TABLE ontology_sources.date_mappings;
       ontology_sources         heap    postgres    false    6                       0    0    TABLE date_mappings    COMMENT     w   COMMENT ON TABLE ontology_sources.date_mappings IS 'This table is to store mappings from precise to imprecise dates.';
          ontology_sources          postgres    false    221            �            1259    45976 	   functions    TABLE     |   CREATE TABLE ontology_sources.functions (
    identifier integer NOT NULL,
    iri text NOT NULL,
    name text NOT NULL
);
 '   DROP TABLE ontology_sources.functions;
       ontology_sources         heap    postgres    false    6            �            1259    45982    historical_evidences    TABLE     �   CREATE TABLE ontology_sources.historical_evidences (
    identifier integer NOT NULL,
    page_from text,
    page_to text,
    publication_identifier text NOT NULL
);
 2   DROP TABLE ontology_sources.historical_evidences;
       ontology_sources         heap    postgres    false    6            �            1259    45988    location_datasets    TABLE     j   CREATE TABLE ontology_sources.location_datasets (
    name text NOT NULL,
    identifier text NOT NULL
);
 /   DROP TABLE ontology_sources.location_datasets;
       ontology_sources         heap    postgres    false    6            �            1259    45994 !   location_datasets_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.location_datasets_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 B   DROP SEQUENCE ontology_sources.location_datasets_identifiers_seq;
       ontology_sources          postgres    false    6    224                       0    0 !   location_datasets_identifiers_seq    SEQUENCE OWNED BY     z   ALTER SEQUENCE ontology_sources.location_datasets_identifiers_seq OWNED BY ontology_sources.location_datasets.identifier;
          ontology_sources          postgres    false    225            �            1259    45996    location_link_types    TABLE     i   CREATE TABLE ontology_sources.location_link_types (
    name text NOT NULL,
    postgis_function text
);
 1   DROP TABLE ontology_sources.location_link_types;
       ontology_sources         heap    postgres    false    6                       0    0    TABLE location_link_types    COMMENT     �   COMMENT ON TABLE ontology_sources.location_link_types IS 'This table is to store link type data for locations, e.g., such links as ''close to'', ''away from'', etc.';
          ontology_sources          postgres    false    226            �            1259    46002    locations_raw    TABLE     �   CREATE TABLE ontology_sources.locations_raw (
    identifier integer NOT NULL,
    the_geom text NOT NULL,
    name text,
    location_dataset_identifer text
);
 +   DROP TABLE ontology_sources.locations_raw;
       ontology_sources         heap    postgres    false    6            �            1259    46008    name_link_types    TABLE     J   CREATE TABLE ontology_sources.name_link_types (
    name text NOT NULL
);
 -   DROP TABLE ontology_sources.name_link_types;
       ontology_sources         heap    postgres    false    6                       0    0    TABLE name_link_types    COMMENT     �   COMMENT ON TABLE ontology_sources.name_link_types IS 'This table is to store link type data for names, e.g., such links as ''is primary name of'', ''is a secondary name of'', ''is a common name of'', etc.';
          ontology_sources          postgres    false    228            �            1259    46014    publication_sources    TABLE     {   CREATE TABLE ontology_sources.publication_sources (
    identifier text NOT NULL,
    bibliographic_datum text NOT NULL
);
 1   DROP TABLE ontology_sources.publication_sources;
       ontology_sources         heap    postgres    false    6            �            1259    46020 *   topographic_object_function_manifestations    TABLE     j  CREATE TABLE ontology_sources.topographic_object_function_manifestations (
    topographic_object_identifier integer NOT NULL,
    start_at text,
    end_at text,
    function text NOT NULL,
    identifier integer NOT NULL,
    historical_evidence integer NOT NULL,
    CONSTRAINT topographic_object_function_manifestations_check CHECK ((start_at <= end_at))
);
 H   DROP TABLE ontology_sources.topographic_object_function_manifestations;
       ontology_sources         heap    postgres    false    6            �            1259    46026 ?   topographic_object_function_manifestation_sourc_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_function_manifestation_sourc_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 `   DROP SEQUENCE ontology_sources.topographic_object_function_manifestation_sourc_identifiers_seq;
       ontology_sources          postgres    false    6    230                       0    0 ?   topographic_object_function_manifestation_sourc_identifiers_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE ontology_sources.topographic_object_function_manifestation_sourc_identifiers_seq OWNED BY ontology_sources.topographic_object_function_manifestations.identifier;
          ontology_sources          postgres    false    231            �            1259    46028 *   topographic_object_location_manifestations    TABLE     �  CREATE TABLE ontology_sources.topographic_object_location_manifestations (
    topographic_object_identifier integer NOT NULL,
    start_at text,
    end_at text,
    location_link_type text,
    identifier integer NOT NULL,
    location_identifier integer NOT NULL,
    historical_evidence integer NOT NULL,
    CONSTRAINT topographic_object_location_manifestations_check CHECK ((start_at <= end_at))
);
 H   DROP TABLE ontology_sources.topographic_object_location_manifestations;
       ontology_sources         heap    postgres    false    6            �            1259    46034 ?   topographic_object_location_manifestation_sourc_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_location_manifestation_sourc_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 `   DROP SEQUENCE ontology_sources.topographic_object_location_manifestation_sourc_identifiers_seq;
       ontology_sources          postgres    false    232    6                       0    0 ?   topographic_object_location_manifestation_sourc_identifiers_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE ontology_sources.topographic_object_location_manifestation_sourc_identifiers_seq OWNED BY ontology_sources.topographic_object_location_manifestations.identifier;
          ontology_sources          postgres    false    233            �            1259    46036 3   topographic_object_mereological_link_manifestations    TABLE     y  CREATE TABLE ontology_sources.topographic_object_mereological_link_manifestations (
    start_at text,
    end_at text,
    whole_identifier integer NOT NULL,
    part_identifier integer NOT NULL,
    identifier integer NOT NULL,
    historical_evidence integer NOT NULL,
    CONSTRAINT topographic_object_mereological_link_manifestations_check CHECK ((start_at <= end_at))
);
 Q   DROP TABLE ontology_sources.topographic_object_mereological_link_manifestations;
       ontology_sources         heap    postgres    false    6            �            1259    46042 ?   topographic_object_mereological_link_manifestat_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_mereological_link_manifestat_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 `   DROP SEQUENCE ontology_sources.topographic_object_mereological_link_manifestat_identifiers_seq;
       ontology_sources          postgres    false    6    234                       0    0 ?   topographic_object_mereological_link_manifestat_identifiers_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE ontology_sources.topographic_object_mereological_link_manifestat_identifiers_seq OWNED BY ontology_sources.topographic_object_mereological_link_manifestations.identifier;
          ontology_sources          postgres    false    235            �            1259    46044 &   topographic_object_name_manifestations    TABLE     �  CREATE TABLE ontology_sources.topographic_object_name_manifestations (
    topographic_object_identifier integer NOT NULL,
    start_at text,
    end_at text,
    name text NOT NULL,
    name_link_type text NOT NULL,
    identifier integer NOT NULL,
    historical_evidence integer NOT NULL,
    CONSTRAINT topographic_object_name_manifestations_check CHECK ((start_at <= end_at))
);
 D   DROP TABLE ontology_sources.topographic_object_name_manifestations;
       ontology_sources         heap    postgres    false    6            �            1259    46050 =   topographic_object_name_manifestation_sources_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_name_manifestation_sources_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ^   DROP SEQUENCE ontology_sources.topographic_object_name_manifestation_sources_identifiers_seq;
       ontology_sources          postgres    false    6    236                       0    0 =   topographic_object_name_manifestation_sources_identifiers_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE ontology_sources.topographic_object_name_manifestation_sources_identifiers_seq OWNED BY ontology_sources.topographic_object_name_manifestations.identifier;
          ontology_sources          postgres    false    237            �            1259    52135 "   topographic_object_provenances_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_provenances_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 C   DROP SEQUENCE ontology_sources.topographic_object_provenances_seq;
       ontology_sources          postgres    false    6            �            1259    46052    topographic_object_provenances    TABLE     4  CREATE TABLE ontology_sources.topographic_object_provenances (
    ancestor_identifier integer NOT NULL,
    predecessor_identifier integer NOT NULL,
    historical_evidence integer NOT NULL,
    identifier integer DEFAULT nextval('ontology_sources.topographic_object_provenances_seq'::regclass) NOT NULL
);
 <   DROP TABLE ontology_sources.topographic_object_provenances;
       ontology_sources         heap    postgres    false    249    6            �            1259    46055 &   topographic_object_type_manifestations    TABLE     ^  CREATE TABLE ontology_sources.topographic_object_type_manifestations (
    topographic_object_identifier integer NOT NULL,
    start_at text,
    end_at text,
    type text NOT NULL,
    identifier integer NOT NULL,
    historical_evidence integer NOT NULL,
    CONSTRAINT topographic_object_type_manifestations_check CHECK ((start_at <= end_at))
);
 D   DROP TABLE ontology_sources.topographic_object_type_manifestations;
       ontology_sources         heap    postgres    false    6            �            1259    46061 =   topographic_object_type_manifestation_sources_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_type_manifestation_sources_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ^   DROP SEQUENCE ontology_sources.topographic_object_type_manifestation_sources_identifiers_seq;
       ontology_sources          postgres    false    6    239                        0    0 =   topographic_object_type_manifestation_sources_identifiers_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE ontology_sources.topographic_object_type_manifestation_sources_identifiers_seq OWNED BY ontology_sources.topographic_object_type_manifestations.identifier;
          ontology_sources          postgres    false    240            �            1259    46063    topographic_objects    TABLE     n   CREATE TABLE ontology_sources.topographic_objects (
    identifier integer NOT NULL,
    default_name text
);
 1   DROP TABLE ontology_sources.topographic_objects;
       ontology_sources         heap    postgres    false    6            !           0    0 '   COLUMN topographic_objects.default_name    COMMENT     �   COMMENT ON COLUMN ontology_sources.topographic_objects.default_name IS 'This attribute stores any name for a topographic object in order to help a human to add manifestation-level data.';
          ontology_sources          postgres    false    241            �            1259    46069    topographic_types    TABLE     �   CREATE TABLE ontology_sources.topographic_types (
    identifier integer NOT NULL,
    iri text NOT NULL,
    name text NOT NULL
);
 /   DROP TABLE ontology_sources.topographic_types;
       ontology_sources         heap    postgres    false    6            �           2604    46075 5   topographic_object_function_manifestations identifier    DEFAULT     �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations ALTER COLUMN identifier SET DEFAULT nextval('ontology_sources.topographic_object_function_manifestation_sourc_identifiers_seq'::regclass);
 n   ALTER TABLE ontology_sources.topographic_object_function_manifestations ALTER COLUMN identifier DROP DEFAULT;
       ontology_sources          postgres    false    231    230            �           2604    46076 5   topographic_object_location_manifestations identifier    DEFAULT     �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations ALTER COLUMN identifier SET DEFAULT nextval('ontology_sources.topographic_object_location_manifestation_sourc_identifiers_seq'::regclass);
 n   ALTER TABLE ontology_sources.topographic_object_location_manifestations ALTER COLUMN identifier DROP DEFAULT;
       ontology_sources          postgres    false    233    232            �           2604    46077 >   topographic_object_mereological_link_manifestations identifier    DEFAULT     �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations ALTER COLUMN identifier SET DEFAULT nextval('ontology_sources.topographic_object_mereological_link_manifestat_identifiers_seq'::regclass);
 w   ALTER TABLE ontology_sources.topographic_object_mereological_link_manifestations ALTER COLUMN identifier DROP DEFAULT;
       ontology_sources          postgres    false    235    234            �           2604    46078 1   topographic_object_name_manifestations identifier    DEFAULT     �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations ALTER COLUMN identifier SET DEFAULT nextval('ontology_sources.topographic_object_name_manifestation_sources_identifiers_seq'::regclass);
 j   ALTER TABLE ontology_sources.topographic_object_name_manifestations ALTER COLUMN identifier DROP DEFAULT;
       ontology_sources          postgres    false    237    236            �           2604    46079 1   topographic_object_type_manifestations identifier    DEFAULT     �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations ALTER COLUMN identifier SET DEFAULT nextval('ontology_sources.topographic_object_type_manifestation_sources_identifiers_seq'::regclass);
 j   ALTER TABLE ontology_sources.topographic_object_type_manifestations ALTER COLUMN identifier DROP DEFAULT;
       ontology_sources          postgres    false    240    239            �          0    45883 	   functions 
   TABLE DATA           <   COPY ontology.functions (identifier, iri, name) FROM stdin;
    ontology          postgres    false    209   ��      �          0    45895    gt_pk_metadata 
   TABLE DATA           v   COPY ontology.gt_pk_metadata (table_schema, table_name, pk_column, pk_column_idx, pk_policy, pk_sequence) FROM stdin;
    ontology          postgres    false    210   ��      �          0    45899    historical_evidences 
   TABLE DATA           h   COPY ontology.historical_evidences (identifier, page_from, page_to, publication_identifier) FROM stdin;
    ontology          postgres    false    211   ��      �          0    45905    location_datasets 
   TABLE DATA           ?   COPY ontology.location_datasets (identifier, name) FROM stdin;
    ontology          postgres    false    212   ��      �          0    45911    location_link_types 
   TABLE DATA           S   COPY ontology.location_link_types (identifier, name, postgis_function) FROM stdin;
    ontology          postgres    false    213   p�                0    47446 	   locations 
   TABLE DATA           ]   COPY ontology.locations (identifier, the_geom, name, location_dataset_identifer) FROM stdin;
    ontology          postgres    false    248   ��      �          0    45917    name_link_types 
   TABLE DATA           =   COPY ontology.name_link_types (identifier, name) FROM stdin;
    ontology          postgres    false    214   ��      �          0    45927    publication_sources 
   TABLE DATA           P   COPY ontology.publication_sources (identifier, bibliographic_datum) FROM stdin;
    ontology          postgres    false    216   �      �          0    45863 *   topographic_object_function_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_function_manifestations (identifier, topographic_object_identifier, start_at, end_at, function_identifier, historical_evidence_identifier) FROM stdin;
    ontology          postgres    false    205   ��      �          0    45867 *   topographic_object_location_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_location_manifestations (identifier, topographic_object_identifier, start_at, end_at, location_identifier, historical_evidence_identifier, location_link_type_identifier) FROM stdin;
    ontology          postgres    false    206   �                0    53381 !   topographic_object_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_manifestations (identifier, topographic_object_identifier, start_at, end_at, function, the_geom, name, type) FROM stdin;
    ontology          postgres    false    250   g�      �          0    45941 3   topographic_object_mereological_link_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_mereological_link_manifestations (identifier, start_at, end_at, whole_identifier, part_identifier, historical_evidence_identifier) FROM stdin;
    ontology          postgres    false    217   ��      �          0    45871 &   topographic_object_name_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_name_manifestations (identifier, topographic_object_identifier, start_at, end_at, name, historical_evidence_identifier, name_link_type_identifier) FROM stdin;
    ontology          postgres    false    207   ��      �          0    45951    topographic_object_provenances 
   TABLE DATA           �   COPY ontology.topographic_object_provenances (identifier, ancestor_identifier, predecessor_identifier, historical_evidence_identifier) FROM stdin;
    ontology          postgres    false    218   �      �          0    45879 &   topographic_object_type_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_type_manifestations (identifier, topographic_object_identifier, start_at, end_at, type_identifier, historical_evidence_identifier) FROM stdin;
    ontology          postgres    false    208   �      �          0    45958    topographic_objects 
   TABLE DATA           I   COPY ontology.topographic_objects (identifier, default_name) FROM stdin;
    ontology          postgres    false    219   �      �          0    45964    topographic_types 
   TABLE DATA           D   COPY ontology.topographic_types (identifier, iri, name) FROM stdin;
    ontology          postgres    false    220   w      �          0    45970    date_mappings 
   TABLE DATA           O   COPY ontology_sources.date_mappings (imprecise_date, precise_date) FROM stdin;
    ontology_sources          postgres    false    221   H      �          0    45976 	   functions 
   TABLE DATA           D   COPY ontology_sources.functions (identifier, iri, name) FROM stdin;
    ontology_sources          postgres    false    222   �K      �          0    45982    historical_evidences 
   TABLE DATA           p   COPY ontology_sources.historical_evidences (identifier, page_from, page_to, publication_identifier) FROM stdin;
    ontology_sources          postgres    false    223   �N      �          0    45988    location_datasets 
   TABLE DATA           G   COPY ontology_sources.location_datasets (name, identifier) FROM stdin;
    ontology_sources          postgres    false    224   �Q      �          0    45996    location_link_types 
   TABLE DATA           O   COPY ontology_sources.location_link_types (name, postgis_function) FROM stdin;
    ontology_sources          postgres    false    226   'R      �          0    46002    locations_raw 
   TABLE DATA           i   COPY ontology_sources.locations_raw (identifier, the_geom, name, location_dataset_identifer) FROM stdin;
    ontology_sources          postgres    false    227   �R      �          0    46008    name_link_types 
   TABLE DATA           9   COPY ontology_sources.name_link_types (name) FROM stdin;
    ontology_sources          postgres    false    228   �g      �          0    46014    publication_sources 
   TABLE DATA           X   COPY ontology_sources.publication_sources (identifier, bibliographic_datum) FROM stdin;
    ontology_sources          postgres    false    229   h      �          0    46020 *   topographic_object_function_manifestations 
   TABLE DATA           �   COPY ontology_sources.topographic_object_function_manifestations (topographic_object_identifier, start_at, end_at, function, identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    230   �s      �          0    46028 *   topographic_object_location_manifestations 
   TABLE DATA           �   COPY ontology_sources.topographic_object_location_manifestations (topographic_object_identifier, start_at, end_at, location_link_type, identifier, location_identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    232   �v      �          0    46036 3   topographic_object_mereological_link_manifestations 
   TABLE DATA           �   COPY ontology_sources.topographic_object_mereological_link_manifestations (start_at, end_at, whole_identifier, part_identifier, identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    234   �      �          0    46044 &   topographic_object_name_manifestations 
   TABLE DATA           �   COPY ontology_sources.topographic_object_name_manifestations (topographic_object_identifier, start_at, end_at, name, name_link_type, identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    236   ��      �          0    46052    topographic_object_provenances 
   TABLE DATA           �   COPY ontology_sources.topographic_object_provenances (ancestor_identifier, predecessor_identifier, historical_evidence, identifier) FROM stdin;
    ontology_sources          postgres    false    238   2�                 0    46055 &   topographic_object_type_manifestations 
   TABLE DATA           �   COPY ontology_sources.topographic_object_type_manifestations (topographic_object_identifier, start_at, end_at, type, identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    239   K�                0    46063    topographic_objects 
   TABLE DATA           Q   COPY ontology_sources.topographic_objects (identifier, default_name) FROM stdin;
    ontology_sources          postgres    false    241   h�                0    46069    topographic_types 
   TABLE DATA           L   COPY ontology_sources.topographic_types (identifier, iri, name) FROM stdin;
    ontology_sources          postgres    false    242   �      �          0    46731    spatial_ref_sys 
   TABLE DATA           X   COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
    public          postgres    false    244   z�      "           0    0 !   location_datasets_identifiers_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('ontology_sources.location_datasets_identifiers_seq', 1, false);
          ontology_sources          postgres    false    225            #           0    0 ?   topographic_object_function_manifestation_sourc_identifiers_seq    SEQUENCE SET     z   SELECT pg_catalog.setval('ontology_sources.topographic_object_function_manifestation_sourc_identifiers_seq', 1291, true);
          ontology_sources          postgres    false    231            $           0    0 ?   topographic_object_location_manifestation_sourc_identifiers_seq    SEQUENCE SET     z   SELECT pg_catalog.setval('ontology_sources.topographic_object_location_manifestation_sourc_identifiers_seq', 5132, true);
          ontology_sources          postgres    false    233            %           0    0 ?   topographic_object_mereological_link_manifestat_identifiers_seq    SEQUENCE SET     y   SELECT pg_catalog.setval('ontology_sources.topographic_object_mereological_link_manifestat_identifiers_seq', 408, true);
          ontology_sources          postgres    false    235            &           0    0 =   topographic_object_name_manifestation_sources_identifiers_seq    SEQUENCE SET     x   SELECT pg_catalog.setval('ontology_sources.topographic_object_name_manifestation_sources_identifiers_seq', 3749, true);
          ontology_sources          postgres    false    237            '           0    0 "   topographic_object_provenances_seq    SEQUENCE SET     [   SELECT pg_catalog.setval('ontology_sources.topographic_object_provenances_seq', 92, true);
          ontology_sources          postgres    false    249            (           0    0 =   topographic_object_type_manifestation_sources_identifiers_seq    SEQUENCE SET     w   SELECT pg_catalog.setval('ontology_sources.topographic_object_type_manifestation_sources_identifiers_seq', 569, true);
          ontology_sources          postgres    false    240            �           2606    46081    functions Functions_IRIs_key 
   CONSTRAINT     Z   ALTER TABLE ONLY ontology.functions
    ADD CONSTRAINT "Functions_IRIs_key" UNIQUE (iri);
 J   ALTER TABLE ONLY ontology.functions DROP CONSTRAINT "Functions_IRIs_key";
       ontology            postgres    false    209            �           2606    46085    functions Functions_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY ontology.functions
    ADD CONSTRAINT "Functions_pkey" PRIMARY KEY (identifier);
 F   ALTER TABLE ONLY ontology.functions DROP CONSTRAINT "Functions_pkey";
       ontology            postgres    false    209            �           2606    46089 &   topographic_types TopgraphicTypes_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY ontology.topographic_types
    ADD CONSTRAINT "TopgraphicTypes_pkey" PRIMARY KEY (identifier);
 T   ALTER TABLE ONLY ontology.topographic_types DROP CONSTRAINT "TopgraphicTypes_pkey";
       ontology            postgres    false    220            �           2606    46091 W   topographic_object_function_manifestations TopographicObjectFunctionManifestations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations
    ADD CONSTRAINT "TopographicObjectFunctionManifestations_pkey" PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations DROP CONSTRAINT "TopographicObjectFunctionManifestations_pkey";
       ontology            postgres    false    205            �           2606    46093 J   topographic_object_location_manifestations TopographicObjectLocations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations
    ADD CONSTRAINT "TopographicObjectLocations_pkey" PRIMARY KEY (identifier);
 x   ALTER TABLE ONLY ontology.topographic_object_location_manifestations DROP CONSTRAINT "TopographicObjectLocations_pkey";
       ontology            postgres    false    206            �           2606    46095 h   topographic_object_mereological_link_manifestations TopographicObjectMereologicalLinkManifestations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT "TopographicObjectMereologicalLinkManifestations_pkey" PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT "TopographicObjectMereologicalLinkManifestations_pkey";
       ontology            postgres    false    217            �           2606    46097 O   topographic_object_name_manifestations TopographicObjectNameManifestations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations
    ADD CONSTRAINT "TopographicObjectNameManifestations_pkey" PRIMARY KEY (identifier);
 }   ALTER TABLE ONLY ontology.topographic_object_name_manifestations DROP CONSTRAINT "TopographicObjectNameManifestations_pkey";
       ontology            postgres    false    207            �           2606    46099 O   topographic_object_type_manifestations TopographicObjectTypeManifestations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations
    ADD CONSTRAINT "TopographicObjectTypeManifestations_pkey" PRIMARY KEY (identifier);
 }   ALTER TABLE ONLY ontology.topographic_object_type_manifestations DROP CONSTRAINT "TopographicObjectTypeManifestations_pkey";
       ontology            postgres    false    208            �           2606    46101 +   topographic_objects TopographicObjects_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY ontology.topographic_objects
    ADD CONSTRAINT "TopographicObjects_pkey" PRIMARY KEY (identifier);
 Y   ALTER TABLE ONLY ontology.topographic_objects DROP CONSTRAINT "TopographicObjects_pkey";
       ontology            postgres    false    219            �           2606    46103 +   topographic_types TopographicTypes_IRIs_key 
   CONSTRAINT     i   ALTER TABLE ONLY ontology.topographic_types
    ADD CONSTRAINT "TopographicTypes_IRIs_key" UNIQUE (iri);
 Y   ALTER TABLE ONLY ontology.topographic_types DROP CONSTRAINT "TopographicTypes_IRIs_key";
       ontology            postgres    false    220            �           2606    46105    functions functions_names_key 
   CONSTRAINT     Z   ALTER TABLE ONLY ontology.functions
    ADD CONSTRAINT functions_names_key UNIQUE (name);
 I   ALTER TABLE ONLY ontology.functions DROP CONSTRAINT functions_names_key;
       ontology            postgres    false    209            �           2606    46109 C   gt_pk_metadata gt_pk_metadata_table_schema_table_name_pk_column_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.gt_pk_metadata
    ADD CONSTRAINT gt_pk_metadata_table_schema_table_name_pk_column_key UNIQUE (table_schema, table_name, pk_column);
 o   ALTER TABLE ONLY ontology.gt_pk_metadata DROP CONSTRAINT gt_pk_metadata_table_schema_table_name_pk_column_key;
       ontology            postgres    false    210    210    210            �           2606    46111 .   historical_evidences historical_evidences_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY ontology.historical_evidences
    ADD CONSTRAINT historical_evidences_pkey PRIMARY KEY (identifier);
 Z   ALTER TABLE ONLY ontology.historical_evidences DROP CONSTRAINT historical_evidences_pkey;
       ontology            postgres    false    211            �           2606    46113 ,   historical_evidences historical_evidences_un 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.historical_evidences
    ADD CONSTRAINT historical_evidences_un UNIQUE (page_from, page_to, publication_identifier);
 X   ALTER TABLE ONLY ontology.historical_evidences DROP CONSTRAINT historical_evidences_un;
       ontology            postgres    false    211    211    211            �           2606    46115 2   location_datasets location_dataset_types_names_key 
   CONSTRAINT     o   ALTER TABLE ONLY ontology.location_datasets
    ADD CONSTRAINT location_dataset_types_names_key UNIQUE (name);
 ^   ALTER TABLE ONLY ontology.location_datasets DROP CONSTRAINT location_dataset_types_names_key;
       ontology            postgres    false    212            �           2606    46117 1   location_link_types location_link_types_names_key 
   CONSTRAINT     n   ALTER TABLE ONLY ontology.location_link_types
    ADD CONSTRAINT location_link_types_names_key UNIQUE (name);
 ]   ALTER TABLE ONLY ontology.location_link_types DROP CONSTRAINT location_link_types_names_key;
       ontology            postgres    false    213            �           2606    46119 ,   location_link_types location_link_types_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY ontology.location_link_types
    ADD CONSTRAINT location_link_types_pkey PRIMARY KEY (identifier);
 X   ALTER TABLE ONLY ontology.location_link_types DROP CONSTRAINT location_link_types_pkey;
       ontology            postgres    false    213            �           2606    46121 %   location_datasets location_types_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY ontology.location_datasets
    ADD CONSTRAINT location_types_pkey PRIMARY KEY (identifier);
 Q   ALTER TABLE ONLY ontology.location_datasets DROP CONSTRAINT location_types_pkey;
       ontology            postgres    false    212            .           2606    47453    locations locations_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY ontology.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (identifier);
 D   ALTER TABLE ONLY ontology.locations DROP CONSTRAINT locations_pkey;
       ontology            postgres    false    248            �           2606    46123 )   name_link_types name_link_types_names_key 
   CONSTRAINT     f   ALTER TABLE ONLY ontology.name_link_types
    ADD CONSTRAINT name_link_types_names_key UNIQUE (name);
 U   ALTER TABLE ONLY ontology.name_link_types DROP CONSTRAINT name_link_types_names_key;
       ontology            postgres    false    214            �           2606    46125 $   name_link_types name_link_types_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY ontology.name_link_types
    ADD CONSTRAINT name_link_types_pkey PRIMARY KEY (identifier);
 P   ALTER TABLE ONLY ontology.name_link_types DROP CONSTRAINT name_link_types_pkey;
       ontology            postgres    false    214            �           2606    46127 ,   publication_sources publication_sources_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY ontology.publication_sources
    ADD CONSTRAINT publication_sources_pkey PRIMARY KEY (identifier);
 X   ALTER TABLE ONLY ontology.publication_sources DROP CONSTRAINT publication_sources_pkey;
       ontology            postgres    false    216            �           2606    46129 j   topographic_object_function_manifestations topographic_object_function_m_topographic_object_identifier_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_m_topographic_object_identifier_key UNIQUE (topographic_object_identifier, function_identifier, start_at, end_at);
 �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_m_topographic_object_identifier_key;
       ontology            postgres    false    205    205    205    205            �           2606    46130 [   topographic_object_function_manifestations topographic_object_function_manifestations_check    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestations_check CHECK ((NOT ((start_at IS NULL) AND (end_at IS NULL)))) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestations_check;
       ontology          postgres    false    205    205    205    205            �           2606    46131 \   topographic_object_function_manifestations topographic_object_function_manifestations_check1    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestations_check1 CHECK ((start_at <= end_at)) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestations_check1;
       ontology          postgres    false    205    205    205    205            �           2606    46133 j   topographic_object_location_manifestations topographic_object_location_m_topographic_object_identifier_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_m_topographic_object_identifier_key UNIQUE (topographic_object_identifier, location_identifier, start_at, end_at);
 �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_m_topographic_object_identifier_key;
       ontology            postgres    false    206    206    206    206            �           2606    46134 [   topographic_object_location_manifestations topographic_object_location_manifestations_check    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestations_check CHECK ((NOT ((start_at IS NULL) AND (end_at IS NULL)))) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestations_check;
       ontology          postgres    false    206    206    206    206            �           2606    46135 \   topographic_object_location_manifestations topographic_object_location_manifestations_check1    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestations_check1 CHECK ((start_at <= end_at)) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestations_check1;
       ontology          postgres    false    206    206    206    206            �           2606    46137 s   topographic_object_mereological_link_manifestations topographic_object_mereologic_whole_identifiers_part_identi_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereologic_whole_identifiers_part_identi_key UNIQUE (whole_identifier, part_identifier, start_at, end_at);
 �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereologic_whole_identifiers_part_identi_key;
       ontology            postgres    false    217    217    217    217            �           2606    46138 m   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestations_check    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestations_check CHECK ((NOT ((start_at IS NULL) AND (end_at IS NULL)))) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestations_check;
       ontology          postgres    false    217    217    217    217            �           2606    46139 n   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestations_check1    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestations_check1 CHECK ((start_at <= end_at)) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestations_check1;
       ontology          postgres    false    217    217    217    217            �           2606    46141 f   topographic_object_name_manifestations topographic_object_name_manif_topographic_object_identifier_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manif_topographic_object_identifier_key UNIQUE (topographic_object_identifier, start_at, end_at, name);
 �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manif_topographic_object_identifier_key;
       ontology            postgres    false    207    207    207    207            �           2606    46142 T   topographic_object_name_manifestations topographic_object_name_manifestations_check1    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestations_check1 CHECK ((start_at <= end_at)) NOT VALID;
 {   ALTER TABLE ontology.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestations_check1;
       ontology          postgres    false    207    207    207    207            �           2606    46144 B   topographic_object_provenances topographic_object_provenances_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_pkey PRIMARY KEY (identifier);
 n   ALTER TABLE ONLY ontology.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_pkey;
       ontology            postgres    false    218            �           2606    46146 f   topographic_object_type_manifestations topographic_object_type_manif_topographic_object_identifier_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manif_topographic_object_identifier_key UNIQUE (topographic_object_identifier, start_at, end_at, type_identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manif_topographic_object_identifier_key;
       ontology            postgres    false    208    208    208    208            �           2606    46147 S   topographic_object_type_manifestations topographic_object_type_manifestations_check    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestations_check CHECK ((NOT ((start_at IS NULL) AND (end_at IS NULL)))) NOT VALID;
 z   ALTER TABLE ontology.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestations_check;
       ontology          postgres    false    208    208    208    208            �           2606    46148 T   topographic_object_type_manifestations topographic_object_type_manifestations_check1    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestations_check1 CHECK ((start_at <= end_at)) NOT VALID;
 {   ALTER TABLE ontology.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestations_check1;
       ontology          postgres    false    208    208    208    208            �           2606    46150 ,   date_mappings date_maps_historical_dates_key 
   CONSTRAINT     {   ALTER TABLE ONLY ontology_sources.date_mappings
    ADD CONSTRAINT date_maps_historical_dates_key UNIQUE (imprecise_date);
 `   ALTER TABLE ONLY ontology_sources.date_mappings DROP CONSTRAINT date_maps_historical_dates_key;
       ontology_sources            postgres    false    221            �           2606    46152    functions functions_iris_key 
   CONSTRAINT     `   ALTER TABLE ONLY ontology_sources.functions
    ADD CONSTRAINT functions_iris_key UNIQUE (iri);
 P   ALTER TABLE ONLY ontology_sources.functions DROP CONSTRAINT functions_iris_key;
       ontology_sources            postgres    false    222            �           2606    46154    functions functions_names_key 
   CONSTRAINT     b   ALTER TABLE ONLY ontology_sources.functions
    ADD CONSTRAINT functions_names_key UNIQUE (name);
 Q   ALTER TABLE ONLY ontology_sources.functions DROP CONSTRAINT functions_names_key;
       ontology_sources            postgres    false    222                        2606    46156    functions functions_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY ontology_sources.functions
    ADD CONSTRAINT functions_pkey PRIMARY KEY (identifier);
 L   ALTER TABLE ONLY ontology_sources.functions DROP CONSTRAINT functions_pkey;
       ontology_sources            postgres    false    222                       2606    46158 ,   historical_evidences historical_evidences_pk 
   CONSTRAINT     |   ALTER TABLE ONLY ontology_sources.historical_evidences
    ADD CONSTRAINT historical_evidences_pk PRIMARY KEY (identifier);
 `   ALTER TABLE ONLY ontology_sources.historical_evidences DROP CONSTRAINT historical_evidences_pk;
       ontology_sources            postgres    false    223                       2606    46160 ,   historical_evidences historical_evidences_un 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.historical_evidences
    ADD CONSTRAINT historical_evidences_un UNIQUE (page_from, page_to, publication_identifier);
 `   ALTER TABLE ONLY ontology_sources.historical_evidences DROP CONSTRAINT historical_evidences_un;
       ontology_sources            postgres    false    223    223    223                       2606    46162 1   publication_sources historical_sources_sources_pk 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.publication_sources
    ADD CONSTRAINT historical_sources_sources_pk PRIMARY KEY (identifier);
 e   ALTER TABLE ONLY ontology_sources.publication_sources DROP CONSTRAINT historical_sources_sources_pk;
       ontology_sources            postgres    false    229                       2606    46164 1   publication_sources historical_sources_titles_key 
   CONSTRAINT     |   ALTER TABLE ONLY ontology_sources.publication_sources
    ADD CONSTRAINT historical_sources_titles_key UNIQUE (identifier);
 e   ALTER TABLE ONLY ontology_sources.publication_sources DROP CONSTRAINT historical_sources_titles_key;
       ontology_sources            postgres    false    229                       2606    46166 -   location_datasets location_datasets_names_key 
   CONSTRAINT     r   ALTER TABLE ONLY ontology_sources.location_datasets
    ADD CONSTRAINT location_datasets_names_key UNIQUE (name);
 a   ALTER TABLE ONLY ontology_sources.location_datasets DROP CONSTRAINT location_datasets_names_key;
       ontology_sources            postgres    false    224                       2606    46168 (   location_datasets location_datasets_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY ontology_sources.location_datasets
    ADD CONSTRAINT location_datasets_pkey PRIMARY KEY (identifier);
 \   ALTER TABLE ONLY ontology_sources.location_datasets DROP CONSTRAINT location_datasets_pkey;
       ontology_sources            postgres    false    224            
           2606    46170 3   location_link_types location_link_type_sources_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY ontology_sources.location_link_types
    ADD CONSTRAINT location_link_type_sources_pkey PRIMARY KEY (name);
 g   ALTER TABLE ONLY ontology_sources.location_link_types DROP CONSTRAINT location_link_type_sources_pkey;
       ontology_sources            postgres    false    226                       2606    46172    locations_raw locations_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY ontology_sources.locations_raw
    ADD CONSTRAINT locations_pkey PRIMARY KEY (identifier);
 P   ALTER TABLE ONLY ontology_sources.locations_raw DROP CONSTRAINT locations_pkey;
       ontology_sources            postgres    false    227                       2606    46174 +   name_link_types name_link_type_sources_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY ontology_sources.name_link_types
    ADD CONSTRAINT name_link_type_sources_pkey PRIMARY KEY (name);
 _   ALTER TABLE ONLY ontology_sources.name_link_types DROP CONSTRAINT name_link_type_sources_pkey;
       ontology_sources            postgres    false    228            �           2606    46175 b   topographic_object_function_manifestations topographic_object_function_manifestation_sources_check    CHECK CONSTRAINT     �   ALTER TABLE ontology_sources.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestation_sources_check CHECK (((start_at IS NOT NULL) OR (end_at IS NOT NULL))) NOT VALID;
 �   ALTER TABLE ontology_sources.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestation_sources_check;
       ontology_sources          postgres    false    230    230    230    230                       2606    46177 a   topographic_object_function_manifestations topographic_object_function_manifestation_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestation_sources_pkey PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestation_sources_pkey;
       ontology_sources            postgres    false    230            �           2606    46178 b   topographic_object_location_manifestations topographic_object_location_manifestation_sources_check    CHECK CONSTRAINT     �   ALTER TABLE ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestation_sources_check CHECK (((start_at IS NOT NULL) OR (end_at IS NOT NULL))) NOT VALID;
 �   ALTER TABLE ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestation_sources_check;
       ontology_sources          postgres    false    232    232    232    232                       2606    46180 a   topographic_object_location_manifestations topographic_object_location_manifestation_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestation_sources_pkey PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestation_sources_pkey;
       ontology_sources            postgres    false    232            �           2606    46181 s   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestation_source_check    CHECK CONSTRAINT     �   ALTER TABLE ontology_sources.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestation_source_check CHECK (((start_at IS NOT NULL) OR (end_at IS NOT NULL))) NOT VALID;
 �   ALTER TABLE ontology_sources.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestation_source_check;
       ontology_sources          postgres    false    234    234    234    234                       2606    46183 s   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestation_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestation_sources_pkey PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestation_sources_pkey;
       ontology_sources            postgres    false    234            �           2606    46184 Z   topographic_object_name_manifestations topographic_object_name_manifestation_sources_check    CHECK CONSTRAINT     �   ALTER TABLE ontology_sources.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestation_sources_check CHECK (((start_at IS NOT NULL) OR (end_at IS NOT NULL))) NOT VALID;
 �   ALTER TABLE ontology_sources.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestation_sources_check;
       ontology_sources          postgres    false    236    236    236    236                       2606    46186 Y   topographic_object_name_manifestations topographic_object_name_manifestation_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestation_sources_pkey PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestation_sources_pkey;
       ontology_sources            postgres    false    236            $           2606    46188 3   topographic_objects topographic_object_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_objects
    ADD CONSTRAINT topographic_object_sources_pkey PRIMARY KEY (identifier);
 g   ALTER TABLE ONLY ontology_sources.topographic_objects DROP CONSTRAINT topographic_object_sources_pkey;
       ontology_sources            postgres    false    241            �           2606    46189 Z   topographic_object_type_manifestations topographic_object_type_manifestation_sources_check    CHECK CONSTRAINT     �   ALTER TABLE ontology_sources.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestation_sources_check CHECK (((start_at IS NOT NULL) OR (end_at IS NOT NULL))) NOT VALID;
 �   ALTER TABLE ontology_sources.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestation_sources_check;
       ontology_sources          postgres    false    239    239    239    239            !           2606    46191 Y   topographic_object_type_manifestations topographic_object_type_manifestation_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestation_sources_pkey PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestation_sources_pkey;
       ontology_sources            postgres    false    239            &           2606    46193 ,   topographic_types topographic_types_iris_key 
   CONSTRAINT     p   ALTER TABLE ONLY ontology_sources.topographic_types
    ADD CONSTRAINT topographic_types_iris_key UNIQUE (iri);
 `   ALTER TABLE ONLY ontology_sources.topographic_types DROP CONSTRAINT topographic_types_iris_key;
       ontology_sources            postgres    false    242            (           2606    46195 -   topographic_types topographic_types_names_key 
   CONSTRAINT     r   ALTER TABLE ONLY ontology_sources.topographic_types
    ADD CONSTRAINT topographic_types_names_key UNIQUE (name);
 a   ALTER TABLE ONLY ontology_sources.topographic_types DROP CONSTRAINT topographic_types_names_key;
       ontology_sources            postgres    false    242            *           2606    46197 (   topographic_types topographic_types_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY ontology_sources.topographic_types
    ADD CONSTRAINT topographic_types_pkey PRIMARY KEY (identifier);
 \   ALTER TABLE ONLY ontology_sources.topographic_types DROP CONSTRAINT topographic_types_pkey;
       ontology_sources            postgres    false    242                       1259    46198 ?   topographic_object_function_manifestations_topographic_object_i    INDEX     �   CREATE UNIQUE INDEX topographic_object_function_manifestations_topographic_object_i ON ontology_sources.topographic_object_function_manifestations USING btree (topographic_object_identifier, start_at, end_at, function);
 ]   DROP INDEX ontology_sources.topographic_object_function_manifestations_topographic_object_i;
       ontology_sources            postgres    false    230    230    230    230                       1259    46199 ?   topographic_object_location_manifestations_topographic_object_i    INDEX     �   CREATE UNIQUE INDEX topographic_object_location_manifestations_topographic_object_i ON ontology_sources.topographic_object_location_manifestations USING btree (topographic_object_identifier, start_at, end_at, location_link_type, location_identifier);
 ]   DROP INDEX ontology_sources.topographic_object_location_manifestations_topographic_object_i;
       ontology_sources            postgres    false    232    232    232    232    232                       1259    46200 ?   topographic_object_mereological_link_manifestations_starts_at_i    INDEX     �   CREATE INDEX topographic_object_mereological_link_manifestations_starts_at_i ON ontology_sources.topographic_object_mereological_link_manifestations USING btree (start_at, end_at, whole_identifier, part_identifier);
 ]   DROP INDEX ontology_sources.topographic_object_mereological_link_manifestations_starts_at_i;
       ontology_sources            postgres    false    234    234    234    234                       1259    46201 ?   topographic_object_name_manifestations_topographic_object_ident    INDEX     �   CREATE INDEX topographic_object_name_manifestations_topographic_object_ident ON ontology_sources.topographic_object_name_manifestations USING btree (topographic_object_identifier, start_at, end_at, name, name_link_type);
 ]   DROP INDEX ontology_sources.topographic_object_name_manifestations_topographic_object_ident;
       ontology_sources            postgres    false    236    236    236    236    236                       1259    46202 7   topographic_object_provenances_ancestor_identifiers_idx    INDEX     �   CREATE UNIQUE INDEX topographic_object_provenances_ancestor_identifiers_idx ON ontology_sources.topographic_object_provenances USING btree (ancestor_identifier, predecessor_identifier);
 U   DROP INDEX ontology_sources.topographic_object_provenances_ancestor_identifiers_idx;
       ontology_sources            postgres    false    238    238            "           1259    46203 ?   topographic_object_type_manifestations_topographic_object_ident    INDEX     �   CREATE UNIQUE INDEX topographic_object_type_manifestations_topographic_object_ident ON ontology_sources.topographic_object_type_manifestations USING btree (topographic_object_identifier, start_at, end_at, type);
 ]   DROP INDEX ontology_sources.topographic_object_type_manifestations_topographic_object_ident;
       ontology_sources            postgres    false    239    239    239    239            /           2606    46204 j   topographic_object_function_manifestations TopographicObjectFunctionMani_TopographicObjectIdentifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations
    ADD CONSTRAINT "TopographicObjectFunctionMani_TopographicObjectIdentifiers_fkey" FOREIGN KEY (topographic_object_identifier) REFERENCES ontology.topographic_objects(identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations DROP CONSTRAINT "TopographicObjectFunctionMani_TopographicObjectIdentifiers_fkey";
       ontology          postgres    false    219    3828    205            0           2606    46209 j   topographic_object_function_manifestations TopographicObjectFunctionManifestation_FunctionIdentifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations
    ADD CONSTRAINT "TopographicObjectFunctionManifestation_FunctionIdentifiers_fkey" FOREIGN KEY (function_identifier) REFERENCES ontology.functions(identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations DROP CONSTRAINT "TopographicObjectFunctionManifestation_FunctionIdentifiers_fkey";
       ontology          postgres    false    205    3798    209            2           2606    46214 j   topographic_object_location_manifestations TopographicObjectLocationMani_TopographicObjectIdentifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology.topographic_object_location_manifestations
    ADD CONSTRAINT "TopographicObjectLocationMani_TopographicObjectIdentifiers_fkey" FOREIGN KEY (topographic_object_identifier) REFERENCES ontology.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations DROP CONSTRAINT "TopographicObjectLocationMani_TopographicObjectIdentifiers_fkey";
       ontology          postgres    false    219    3828    206            <           2606    46219 s   topographic_object_mereological_link_manifestations TopographicObjectMereologicalLinkManifest_WholeIdentifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT "TopographicObjectMereologicalLinkManifest_WholeIdentifiers_fkey" FOREIGN KEY (whole_identifier) REFERENCES ontology.topographic_objects(identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT "TopographicObjectMereologicalLinkManifest_WholeIdentifiers_fkey";
       ontology          postgres    false    219    3828    217            =           2606    46224 s   topographic_object_mereological_link_manifestations TopographicObjectMereologicalLinkManifesta_PartIdentifiers_fkey    FK CONSTRAINT        ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT "TopographicObjectMereologicalLinkManifesta_PartIdentifiers_fkey" FOREIGN KEY (part_identifier) REFERENCES ontology.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT "TopographicObjectMereologicalLinkManifesta_PartIdentifiers_fkey";
       ontology          postgres    false    3828    219    217            5           2606    46229 f   topographic_object_name_manifestations TopographicObjectNameManifest_TopographicObjectIdentifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology.topographic_object_name_manifestations
    ADD CONSTRAINT "TopographicObjectNameManifest_TopographicObjectIdentifiers_fkey" FOREIGN KEY (topographic_object_identifier) REFERENCES ontology.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations DROP CONSTRAINT "TopographicObjectNameManifest_TopographicObjectIdentifiers_fkey";
       ontology          postgres    false    3828    207    219            9           2606    46234 f   topographic_object_type_manifestations TopographicObjectTypeManifest_TopographicObjectIdentifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology.topographic_object_type_manifestations
    ADD CONSTRAINT "TopographicObjectTypeManifest_TopographicObjectIdentifiers_fkey" FOREIGN KEY (topographic_object_identifier) REFERENCES ontology.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations DROP CONSTRAINT "TopographicObjectTypeManifest_TopographicObjectIdentifiers_fkey";
       ontology          postgres    false    219    208    3828            :           2606    46239 _   topographic_object_type_manifestations TopographicObjectTypeManifestations_TypeIdentifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations
    ADD CONSTRAINT "TopographicObjectTypeManifestations_TypeIdentifiers_fkey" FOREIGN KEY (type_identifier) REFERENCES ontology.topographic_types(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations DROP CONSTRAINT "TopographicObjectTypeManifestations_TypeIdentifiers_fkey";
       ontology          postgres    false    3830    220    208            ;           2606    46244 ,   historical_evidences historical_evidences_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.historical_evidences
    ADD CONSTRAINT historical_evidences_fk FOREIGN KEY (publication_identifier) REFERENCES ontology.publication_sources(identifier);
 X   ALTER TABLE ONLY ontology.historical_evidences DROP CONSTRAINT historical_evidences_fk;
       ontology          postgres    false    216    3820    211            1           2606    46249 X   topographic_object_function_manifestations topographic_object_function_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestations_fk FOREIGN KEY (historical_evidence_identifier) REFERENCES ontology.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestations_fk;
       ontology          postgres    false    211    3804    205            3           2606    46254 j   topographic_object_location_manifestations topographic_object_location_manifest_link_type_identifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifest_link_type_identifiers_fkey FOREIGN KEY (location_link_type_identifier) REFERENCES ontology.location_link_types(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifest_link_type_identifiers_fkey;
       ontology          postgres    false    213    206    3814            4           2606    46259 X   topographic_object_location_manifestations topographic_object_location_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestations_fk FOREIGN KEY (historical_evidence_identifier) REFERENCES ontology.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestations_fk;
       ontology          postgres    false    211    3804    206            >           2606    46264 j   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestations_fk FOREIGN KEY (historical_evidence_identifier) REFERENCES ontology.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestations_fk;
       ontology          postgres    false    211    3804    217            6           2606    46269 f   topographic_object_name_manifestations topographic_object_name_manifes_name_link_type_identifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifes_name_link_type_identifiers_fkey FOREIGN KEY (name_link_type_identifier) REFERENCES ontology.name_link_types(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifes_name_link_type_identifiers_fkey;
       ontology          postgres    false    207    3818    214            7           2606    46274 P   topographic_object_name_manifestations topographic_object_name_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestations_fk FOREIGN KEY (historical_evidence_identifier) REFERENCES ontology.historical_evidences(identifier);
 |   ALTER TABLE ONLY ontology.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestations_fk;
       ontology          postgres    false    3804    211    207            A           2606    46279 W   topographic_object_provenances topographic_object_provenances_ancestor_identifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_ancestor_identifiers_fkey FOREIGN KEY (ancestor_identifier) REFERENCES ontology.topographic_objects(identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_ancestor_identifiers_fkey;
       ontology          postgres    false    3828    219    218            ?           2606    46284 @   topographic_object_provenances topographic_object_provenances_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_fk FOREIGN KEY (historical_evidence_identifier) REFERENCES ontology.historical_evidences(identifier);
 l   ALTER TABLE ONLY ontology.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_fk;
       ontology          postgres    false    3804    211    218            @           2606    46289 Z   topographic_object_provenances topographic_object_provenances_predecessor_identifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_predecessor_identifiers_fkey FOREIGN KEY (predecessor_identifier) REFERENCES ontology.topographic_objects(identifier);
 �   ALTER TABLE ONLY ontology.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_predecessor_identifiers_fkey;
       ontology          postgres    false    3828    219    218            8           2606    46294 P   topographic_object_type_manifestations topographic_object_type_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestations_fk FOREIGN KEY (historical_evidence_identifier) REFERENCES ontology.historical_evidences(identifier);
 |   ALTER TABLE ONLY ontology.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestations_fk;
       ontology          postgres    false    3804    208    211            B           2606    46299 ,   historical_evidences historical_evidences_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.historical_evidences
    ADD CONSTRAINT historical_evidences_fk FOREIGN KEY (publication_identifier) REFERENCES ontology_sources.publication_sources(identifier);
 `   ALTER TABLE ONLY ontology_sources.historical_evidences DROP CONSTRAINT historical_evidences_fk;
       ontology_sources          postgres    false    229    223    3856            C           2606    46304 j   topographic_object_function_manifestations topographic_object_function_m_topographic_object_identifie_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_m_topographic_object_identifie_fkey FOREIGN KEY (topographic_object_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_m_topographic_object_identifie_fkey;
       ontology_sources          postgres    false    230    241    3876            D           2606    46309 j   topographic_object_function_manifestations topographic_object_function_manifestation_source_functions_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestation_source_functions_fkey FOREIGN KEY (function) REFERENCES ontology_sources.functions(name) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestation_source_functions_fkey;
       ontology_sources          postgres    false    230    222    3838            E           2606    46314 X   topographic_object_function_manifestations topographic_object_function_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestations_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestations_fk;
       ontology_sources          postgres    false    223    230    3842            F           2606    46319 j   topographic_object_location_manifestations topographic_object_location_m_topographic_object_identifie_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_m_topographic_object_identifie_fkey FOREIGN KEY (topographic_object_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_m_topographic_object_identifie_fkey;
       ontology_sources          postgres    false    232    241    3876            G           2606    46324 j   topographic_object_location_manifestations topographic_object_location_manif_location_link_type_names_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manif_location_link_type_names_fkey FOREIGN KEY (location_link_type) REFERENCES ontology_sources.location_link_types(name) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manif_location_link_type_names_fkey;
       ontology_sources          postgres    false    232    3850    226            H           2606    46329 _   topographic_object_location_manifestations topographic_object_location_manifestation_sources_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestation_sources_fk FOREIGN KEY (location_identifier) REFERENCES ontology_sources.locations_raw(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestation_sources_fk;
       ontology_sources          postgres    false    227    232    3852            I           2606    46334 X   topographic_object_location_manifestations topographic_object_location_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestations_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestations_fk;
       ontology_sources          postgres    false    3842    232    223            J           2606    46339 s   topographic_object_mereological_link_manifestations topographic_object_mereological_link_man_whole_identifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_man_whole_identifiers_fkey FOREIGN KEY (whole_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_man_whole_identifiers_fkey;
       ontology_sources          postgres    false    234    3876    241            K           2606    46344 s   topographic_object_mereological_link_manifestations topographic_object_mereological_link_mani_part_identifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_mani_part_identifiers_fkey FOREIGN KEY (part_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_mani_part_identifiers_fkey;
       ontology_sources          postgres    false    234    3876    241            L           2606    46349 j   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestations_fk    FK CONSTRAINT        ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestations_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestations_fk;
       ontology_sources          postgres    false    3842    223    234            M           2606    46354 f   topographic_object_name_manifestations topographic_object_name_manif_topographic_object_identifie_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manif_topographic_object_identifie_fkey FOREIGN KEY (topographic_object_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manif_topographic_object_identifie_fkey;
       ontology_sources          postgres    false    241    3876    236            N           2606    46359 f   topographic_object_name_manifestations topographic_object_name_manifestation_name_link_type_names_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestation_name_link_type_names_fkey FOREIGN KEY (name_link_type) REFERENCES ontology_sources.name_link_types(name) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestation_name_link_type_names_fkey;
       ontology_sources          postgres    false    228    3854    236            O           2606    46364 P   topographic_object_name_manifestations topographic_object_name_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestations_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestations_fk;
       ontology_sources          postgres    false    236    3842    223            P           2606    46369 W   topographic_object_provenances topographic_object_provenances_ancestor_identifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_ancestor_identifiers_fkey FOREIGN KEY (ancestor_identifier) REFERENCES ontology_sources.topographic_objects(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_ancestor_identifiers_fkey;
       ontology_sources          postgres    false    3876    241    238            Q           2606    46374 @   topographic_object_provenances topographic_object_provenances_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 t   ALTER TABLE ONLY ontology_sources.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_fk;
       ontology_sources          postgres    false    223    3842    238            R           2606    46379 Z   topographic_object_provenances topographic_object_provenances_predecessor_identifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_predecessor_identifiers_fkey FOREIGN KEY (predecessor_identifier) REFERENCES ontology_sources.topographic_objects(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_predecessor_identifiers_fkey;
       ontology_sources          postgres    false    241    238    3876            S           2606    46384 f   topographic_object_type_manifestations topographic_object_type_manif_topographic_object_identifie_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manif_topographic_object_identifie_fkey FOREIGN KEY (topographic_object_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manif_topographic_object_identifie_fkey;
       ontology_sources          postgres    false    3876    241    239            T           2606    46389 _   topographic_object_type_manifestations topographic_object_type_manifestation_sources_types_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestation_sources_types_fkey FOREIGN KEY (type) REFERENCES ontology_sources.topographic_types(name) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestation_sources_types_fkey;
       ontology_sources          postgres    false    242    239    3880            U           2606    46394 P   topographic_object_type_manifestations topographic_object_type_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestations_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestations_fk;
       ontology_sources          postgres    false    239    3842    223                       0    53622 )   geonode_topographic_object_manifestations    MATERIALIZED VIEW DATA     N   REFRESH MATERIALIZED VIEW ontology.geonode_topographic_object_manifestations;
          ontology          postgres    false    255    4109                       0    53446 1   topographic_object_function_manifestations_filled    MATERIALIZED VIEW DATA     V   REFRESH MATERIALIZED VIEW ontology.topographic_object_function_manifestations_filled;
          ontology          postgres    false    251    4109                       0    53453 1   topographic_object_location_manifestations_filled    MATERIALIZED VIEW DATA     V   REFRESH MATERIALIZED VIEW ontology.topographic_object_location_manifestations_filled;
          ontology          postgres    false    252    4109            	           0    53457 -   topographic_object_name_manifestations_filled    MATERIALIZED VIEW DATA     R   REFRESH MATERIALIZED VIEW ontology.topographic_object_name_manifestations_filled;
          ontology          postgres    false    253    4109            
           0    53464 -   topographic_object_type_manifestations_filled    MATERIALIZED VIEW DATA     R   REFRESH MATERIALIZED VIEW ontology.topographic_object_type_manifestations_filled;
          ontology          postgres    false    254    4109            �   �  x���[n� ���*��y��Ҵ���4"�:�Y�8jQu��I�571��V�%���s�nZ?6����V�z#�����ߞ���K�����6��炏ZjAP����-l.�,����SG@X$�"-����Lh��ӛ�`��-��rN�S�j���y��r�Y3R0<R����>/��7��_�6���d{N��"�NN�A�s���9��k���'X�X�������厯�A)�����^I꬀�{L)��J�k�9�P��m��E�*Ӟa˲�!w6j�-u^�Q�eM q)d���1��:$\K��"�:P�4F��_N�x�No>�/�\��R3�t1}W
n��'��K�cழj`�;�]�1eQ��k+{#�r�)��J-��:?�R˳�4�6���$�B���&���ya�s?�>�
����7a� V�]���oSsHFwcFgQ�t�¡N�ξ�p�� ��A�S��w�W)���\-3pxU+2���>
���&q|��`������7��И� �Zsz�3�H�P���U�<Ɖ����}�"�ǕOȹ���G�HY�y`R�A1��>�n��fPC��N)<�ە�);�s�_���c�v$�{�)�4$
�3Y��g�
]0Yz �4��ŻV��S-c��TCu�c>�/���9�v�6�� /�����P��ne�/�����Z*nz<�j�,���Ə�,#xǠ�������      �      x������ � �      �   �  x�uT�N�@>{^�s�w���׊��5THɚ8[���E#+��*A�'�Wg�xԕ�9�7��~c�]��d�X�̘K��<���v6�f7�����E��+|�զ�TLHH{�W���y�R����5��� }���=�c6ŵ�=Յi0������X؇}Qv����;�n��;�q!,U��AH�3	0��Զ��=-�k�/+����u�D�Q�J�|��Y�х~P����%|��dO�ֺ��m��J�����ǔv��p����'�R��8vy2�X�R�J�� ��[�̳t���T��^�3s��Xi�����8`QGCt���*��f�<N��=���L�xp�-ʺ��5fQ����!\�*o�����Et;��fcM�}�M��e��S��4<�O���K�����oa�|)D�V$���!D���ͦU=C�czor=q���}�XR[���5q}�M�VSR���"h7h7m��v�k�/��4�l[ᆂ���^~�Ƹ;�+9:R�Պz�O�j�6����N�|��33�
�	�337�?�Y��e��,I N�,��q������ԉ�3���~��]!�����$OƔN� mi�D:�6�F����S��Xj�T���2�+V�Zmڼ�N_���{n^�4�����I�1'Ut�TF��Ԏ'(3��s���z;j�=��C,P/N�x�>��ū-݀_����
�F �Vc�:      �   z   x�3�Tv��O�I�M,(�2�T҉�Ʀ\Ɯ��)�9\&��>�y)9��\���n�%��@E��@5f��9�y�\�P����DKjN%�%���G�obU~yqU*��Ĉ�R�1z\\\ ��$G      �   	  x�m�Mn�0���)8A�m~/�d1R���,Xr����6�����.�����f��0�؛���k��q��؜:sGU��Z��R�{R�S�K"�m�Gۘ\�����X�g�s��H�ZL ������I���BQz�f����b��p
:о�uobٿ�sP��BA*)�Z�*R�O`rÙ���D�p�u(��;ħVc�'� W�;�Y�q���v'Z�BK����A���*bS�e"ٶT�D���og�~)�����[E� ��s            x��[]o7�}�~E!O���,~`�(z֎3B���1/�VE.��%Tw���m��7d�3򶛷X�kY��d3�c$��l^���{�yT�������C�0K��5e%�5+%-+g�'�*�f�#Ӯ��0}{��}�ϯO�Je��]M(�5�䍱���r��,�E[�����x��a<��} �@��mxU�r,-��啭�[������j�վh����oW����K7v����,��%�\hJ�%*U����������EIf��~Ϡ��F����NgPs���-�gp�w�p
�M�v���yqx���Oo�縑�o�x|��Vm!�(Vc��� �}��s�3�:	�J�G���yj�ž����x�.�bW�l�����]��ڔ�PW���qX���śF��e�k���|Q<���U��7�ū����a�}Ql�_��n^��ȉ�,FiC��Z��[B\��i����][�O��e��}���/��j��u���_#�%������`�˰A�Y�4�hUS�K�4����ѳ�}3\����x2���n���Y<�n�l�W��k?�NH��>���~����2V�m�nj5,V�&'�d�U�(k���^�kiJU�R��tR��[m��P���?�z��>!9�V�Z[-9|'�AY3M\�%q��u�x]|�͎��z����;�������w��7�z�o?��l�*J)>-��OkC�;�n������gf /�v�߻q�},�y�����|�A�D�Z:�$�g�\��K�~��g�8,�q�� @0<��]�?1�b'��u��i���i{�=k�e�NhU����T����R���p2{�x��χ���huXF��G�׷o��\|��^X�\�9���Z�U�q�
�mM���௷#h�X�f�.���fr��>k=LC���e�&���%Q�Hm*2]	SFU��Τ��q1���y�]�/�ݾ�n9���{w�����?�璅*5��N-ܹ��FM`�o���u���(n��P��f��wc+�!�Ff�G�l��]����o�O�5뼧��ۢ/N�����r��5���8/��D)�--��.���ط����_�[��Se]>�RM�B�z&ޓh�
���~�y89+"k#����p�D8�V�:��;;$�q�Ű�Qqj�UV8>�{�5�l>���E�`/�g}w��ߓ�,^�qFX�9&���DIS@#��?��9�Y�/^��g�*���U7\p����;��.pD4G`K�A;����B�&^'7q;(�n����(Os�t���l�eJGNj�\�m�rƫ��; ���z�^��p:��.���X�&���=,���C }6	v6�[��ͰL&��i3\�_\5\K�)�^���ƲZ���7��%�Zq�d�>l��U;� �*�9FY@!�9A�:j��=^[������,��(,�1Bv"�$�s�B�Dri��,و
����9�E��=��J�5C�o�t KBbQ�B�9�'d�B�� �>��_#4kHt4�F-2~���!��ZU����k�x}Q��(晐�Ye�D1.�9�g}�h\��r��F�ʔ��P���i���؝�c�cAU��*h��o崦J+����Jqӎ��}�Dd���O�N�f׮.:ҫ�s8?��S��,!��ÔC0�E:���n��a9\��jg5b&�G��4VI��nJfP��:��a٭���^��+��[���dPQ]@I�s�H2zbl_\v�p�H��t��ZV>��#0cD
8xO�[�QÜ,�1l��������/�2�U1�u�U,�<��Q���i�KUZO.몆TDZ5�Н��2	3�I������ɼ���Z5�"a=O���ٸ�W�m��6��3$wQ;s�i)�b�dS�D�]1Z)�*���bl@j���ʤ�qu`\t:KT.���g��~�_�3޽�qq�O�~	�:G])%�(����k4��u�h#�I��c�B2h9R���"D��SQ�Ե@K��b8����^vWkds���]R�1�a�-~�����URU�|�Ih�l�2��o��⻗�6��>�F~<t�F!vn~��!�:-�|�[c�P��(�A	���s��B9��t�;f���yζ�{pa�|"N�r��:���L0��!��ܣd���W���ƶG���W�ij�+�������~<�=�{���6~��\�7��v��B�nC^<ů ��Ɏ��@��(#!^&���hW�����h�i��뭯D�S���2f��q�9�Zi8��tS�3�=�zV�&�pw���z{�b&��-+p-�Us.Rm���(�%�U������n�<��#+L��Hf�	˗^�X���;x�m��a7$i[FY�r������ռ�D>�Գ���d;���ˊ�Y3�IM]ͭ8�,u��=��>t���㡬S��U�qZ�]��bw���	�1N��H�?����8ǄB��$T^D���6$��-�����op��-�t����ĳ�D�f$2F�/��'�T��)v�X^�܂�܆䜤�Y�JT	�J��p��H27�H7n/~5��@y�U������&��D�ګvr��2�7L''Fb��?k�H�]����9*Hd.؁26�������O(�+A�y�Nk����
�F�G�8W���=�oX߱H�8Pו����V���9�9P�2��t8��&cr��/Q�&�mϭ�3��c�� A�����sTNF"�C��!+Y�ߠ��v�_dE�F�tJL"\+�蒺��}�_A-D�-���d4U,Ilb[���|�i���M��oꦞ����x
Ŕn�]����p6�5o(�j����n��Ԝ)���K(P��_$�?�� ��<�m��f�S��(���u���m�=d�*�Q�Z�ȼ���2���h�u�t����"����� ��p%j"�t�|O�!sԨ��� �b��V��.�yC�F�*y�Uθ�|�|��Y"���W¢g��D�EA���G�m-W�k�n( ��	B��ħzlN&���}����:�ي'\���9 /kڝӚ�D�q����P]�ȵi,$�3l���Z��c����6%�D@��%S��&--M5˅��qj����d�qo��P��&��P�;T�L�x�1��-s��Rk�n��J:���P�?�81�o�sF]ɕND��	*kCR 9���l�:Z�r��AmT3':۠/͜U&�y�B�m�A��]�si;�����A�0�5=��n ���y*��t@))�.$����L/����oH4�ɸ�w�����)OT�>�}�+�,-�O��т� ���
Oa��چbR��mh�|ߏ���Iw�m^���苗������-8ŝ����RjȮڊ�^4�6ʸ��w�dX���y{�qdQO�q�@��ZUlj��LjYQ��d���
�����F<^n��(�B�{su�?E�xN)�jP=�i�z������40���j������8ͱLhg5��@�.������V��2��^q���q!T娨r[P��	�,����S����*�_}hp�"7�0��*h8����ͮ�@���!L$ Զ��]���D;�,��-ND�J)M�K�uU7�:�H�0nB�>q:�2���}sKx�B3-M�p]���Ʉg����[�^�\���U*���E	�'jU�p�"Ʒ]��,0�O6����w"eHM�����;(_u����'�Acꔅ�`��t�~�ɀ+A=I�a��x��^j!���������%��ߊo��b�����wc���ٰ�^��������upf��v�֚�@���I��F'_m�խ�@�6^m���±�ۘ�X��`�6F����X�=�p�$G����hI���pƘd	r�6f�Zrl$M�:��ܾ1�&M����pbR����~�4��H��ᩆӲN]�P��iC�%&�r�� x-����T�Y�,�����ZQ��ڔ�^���Bȣ�=�i{����G�>�a����4��������_�履���?/��X�d_L(��i{�}E��j�]���/���a����}R�>ұ�=� >  �p��WH�`�)�����[���b?!f��� �G%���*�m4j9͑���J���͔}��t#SE�2X����9�խ��x|�Ds|'�}���P9�T5�5�^թPqJ>Ι�nIWd�$������'sJ��x;����PD����Bf��"���k��������]g�a˾8 =C!e��Z�؉�0g�1�@z���t5�d�xI���&�X����=������~�^@�E�촄��Y.q(��؝.5���ξh�Ԯ�-YT^Jr���<�}�z�?[�æ��z�=o��f��ep���tf#qy�4��0�Ty|�3�7��Nf_POC����"��I��X�Gw��p�prū�JC��J��0v�)����+$��Ӏ?�Bjv�O ���"Sn�Ux�z�3�M7Ƽ�H�����YTz�s6?�!���{�΄��W�f���y>�i�Jr.���Q�'9��Eǖ�dR�����kr���Oi�?����'�������HIA�n~�N�AaW��X��������v��I4�N��l��#��9t���f���I ��䓬��N�?������GL|١��P������oY�������!0É'"[V;�n"��z2<i�&�G� =���4?�ޣ��}�̀���}���>}h��k}�/������\�jjkQ���klEq>��	6q����rd@�~ڂUs,�7�J�,� ���
��v��po�-�;��_�?;�v����O�b�4��(^���-l��W$;�~&�"�w��9���"�(?��=C<�[����j��Z�jS��� z�����?a_w֊.���7��VTZ��S�&�������k�8Ȝ�'��m�D9������%7�e��7�G`B�Ϻ,^�����S�И����Ka�q89�{����axFw�&G����$=J5�<��������m7��/S��N�k7]x�׌��!��y������	���)ٱ�4uܾn��<X�2���XnLKLa�FY���=�x9�>���f���J�#�O�(;��Ej���%�6��
s���v^#\D\%G;*dSKiX���[�%~�?���p���~~U����k���8�*	cUA��;�V��Y�y�F��O��*�?���c�'Be_q	A�{�6uUo�؈j���~�?��K�a�� ��������ǋ�����1կkx$�)�x+J�e3���p�ꯦ�	z�/���q��2%�����l�:�j	B�4���Sy��bR�i*����\���ߝ��qXE�~yrr���v[�      �   +   x�3��K�*OT(�O).I,�/O�2�
�'�'W�%r��qqq ��      �   �  x��XMo�H=˿��&DJ���9y��p'F�ā���"�r�[Ï!�SƘ��y�2��.�?�6�i����}�%ZH��v� ����W�^���4�epጆ�F�ܤ'6��t��v���ߎ�"P����_��z��B$9�����O�LDq!��W�O��4�8ҡ�˯:M���_{w�I��M�Χ׿v�������v���=���A�^�D�I	��$w�,�=���"����v>>��5�?�B-�9MzhӹM"��N���k�6�^��^��v�X$"�S<��û��E��
�('z�}_||�|������8�\M�XBw��et��ؕ6�e�=2�y����h<:><�k���5���:��˷M:*}�^�k���.��ӱ���a����a^�n��>j?��gXP r�z}��:7���
F�|��*�g �o�0<M^�䌝�����_�56ܫ���t�{"��d�N��C&����8ɓ4I�B\#����9	�my��_ 9)��D��C��Ii���ؼ��σ�t�X*钘h�#��J�^�X`�27��z4��u�e�-n��$�ll�iwڍ�+� @�Q!���?�^=�3��J����=�ݫ@H��sʔ��vz�E8��'��o���T���_N���Ϟ��v���H�������>o�OD{5���q|)r���gY,9�ʭ':�sqkc���2��I���n��g�SN��
��_�JF�������k�i>����&�uF �����&��� �@���Z�.��7~xW�K�N�+��周�4Q��G"�9�@;O�O�J������N���xO�{\#�8��ƭ�'�|�E��I�Mݎq����)�X,1�i�_��a��.RwN��Z�Hn���˷�졀���'",�	{+���-c����Y�vx:S�ZHO���i���
Dh��ۨ4+�FR-��1�rN�+�V��*f��S���2r������ cHlvdV�����Ur���3���<��`쭽I��!`u"�H/t ��NH���C*7ˣ0�.����{șW��Ja�Ic�lI��ƾkk����a�&#�>~����\�����}�ECS�}x�����s�������je%o�%���8�͈��wxx�����!�I$���)��:�e��VuF�N�6Ф����&�6���>��QM@�� �́���i�i�,C�y��R7z����_��'fn��|~�����4�Ms��%��h	Z@�@�Tq?�9Wt/@=���Q!�1?!/����o��2b�+�9싊>�b׳c	S�&�Ȓ|� ����T`���<y����V�+�Ӄ�r� ����űFa�M�v�.���n;�v���tx�7��?����|P��*=|��~�.=��q��I>�T�T㱘F^��@M�,�MrYn���7X/��ȶ./Xs���*�̶�/�����O)*���4��`��D���Y!|�X�����Y�e\�j�c�<�	���1�"�Ɯ�킗�ol\�M�[��@���N�VI�z=k��ΧA�s�4h�uQj���lfB�踐�J�Fm b�.k젷˺�Z��O�o0�d���F��u��Ac�2�&[ �!��~_,ù��L@VDF0l�
�a����a��>]%�"�o�.'��P����P&�"hy2�̸��ڟ㳛_bE9/u�Ĕ�^g��t����P�)�N$�9��of����C��(�"��F$ T�߬v���t'���ۥ{�;[R��F��s���,�쭙-=�JKZ����t��ueKo��>�
�B5c�<s����a���_)�|.���H����#�?��|�]��Z�6��c���4+�R ��\�:{Mz�l3�k���L	o�|����N���M�P���A:MYG"��Xq����@BG��8t� �G�kz���; ���?��'X���_��A,��ΰQ>�sY�A=d"W��'�E��+E#�oh��X�g�BM��gs�{�xCͮ:�ab�TŅ��}E8/'�ܦ��ٯ��t���ct�0�e�\��¤)��)�HH0��K�aˊ�!�ɕ5'wʅ+!Gɕ��`��AG������K� f�z���OC�UY1�`ř%��Xae��i�8��6v!U�#�L0���u���QPU}��e�Ƞ�<U&�8OdR���P�xEN�K����/����(S0�?�:�JU+�� �.�9���5���P�va��������w':4�>7;�G�V�UTL�1C����������`ů���א�f����
� �d˝ǭy��%'Z���w�*Ͷ�f[7̶�l���vY'#ww�\I�U�|�I�D��C}��4���d�6.|#��3�L����!�?�n�aa����gѭ���֮*���f���t=ϰ[c�����U��i7x`�SM��1�x��ȼ�)��u˨�y�2ھ��d�{2tg:D~��E��(��}*���7��7�]v}v�O
�A��Z�ݼ�����z�� ���Br��˾x~ttԤG/��/�+���
`�+�Ay�3z�k��o_��B�ը�i<�{����̮����L%�b�&�]���˷{Y6L�9���h�R�C���������%/M�u�Ȩ����)+�W���Ack�I���:�?�w�g���t(&EU�Dlm�7p�ڕ��z��1ԤF�r?�����ݕjbSCע���7w���х�����˷�ց��Mf��:��a���>���.5�)�g}�	�>p3��ygp3רE/��F��%=L��=�a��hт�����[�r~�W*�������n��Z�������J��f&ݤu��Z̅djy���u(/E$;�繁�ڥ�)Z8��n��S��mP߿��|��{�: L�t^�A�m�F4׶qXfW����yka�ՙUTZ��jA�\�ʪ����Ǉ�g�� �����55�H�)@�D�o�'��,ɚ�d���������M      �   
  x�}�Y�� D�Uw�	� �]�������QD�L-�ٝ�X{�)�?���8��R>�y"�~]���H��32>g���XNDN�� ;%I7Q&u���"J̜�lZa$i	��B�̀ڈL#M?�듑�0�T��R`���bd�i@�4�^�3L&řU��<�ղ�<�d�=��`�ԑVՒ
FI��䅧ѓ1�rO]c�uHU2�_�i�idY���N7��?#m N�6�=sJ����^2ଶd�����+m~�4
)�/&��8>�z���R�ᾦXۦ�lT�|ix�9W�($���L)��p�/[/��>��KuP\@955YU.��8"�	��s֧���ؤ�d֘�m. &�Ã�"�y�5r�/������Ip�P���_秢�Ƥ�\�z8J�p�fϸ���~�S�4��{\G�Tچ��:wQ^<v!T]7�4bam��*[[���`219�u�U��>v��t`�+��˄�v_���D�/�� ��o�)L�4���|>�r+�      �   I  x��Yk��)�M�eW�1����ϱ.	�"M4T�lSv�KH!�1��I?!��אb�!��kȺ��Z��P���҂�*�oH���+��PH��J]��	���D`$t����~n��a��4k}�!�"�}?(�H����-~��2�7�_0n>�+H���=��E?U�'��Cp��~�ϐ_wS駔Mym�f��H��������JWKB(ǐ�0�&do;B��� ���j}�$�0�0��)�&l�������r�0=����3,;	��d�T��%��?q�rGA�,t���[�E�����u27C�p��t)x�+NA���r<q{
*J��v���T
�%w_�?A �
��f�����.b(MF0w=�qe�2�����|�����C���>(���5��9"7[Dڹ�P�^|񄅡&"W=6.��U���7���`���t����Ai:����`O��E�Kn��M�d�j� r����WC�P+�f�W��d(�;����=x�$��yKD�Ɖ�ґ�/'L�:����IC@�SP�M�}�֗ە�H�>��Q:������H�2��*P%��.'"�V��1��M��:P-43<���򪡅xo=�9=�%ޕ��:����+��6W^�綣�:�Z���dP3��Kz����1��K��|���^��I����%
Bi�J�/;>U(}ӹc�OT=���(��J���G��ͯ���:���r���T���C����U��C?�����r������1r蓗��|�J�mi��'T��ȼ�h��P�����&m�X�����{�w.�Y�z��˖8j����R	�\�m��e�mKb�Dmk�,��+���Z�4m�j�L��;��V��@���+p��S�O�G�)"�A٥��d�$e�N<&H2N-��x9_�gA�p���gAfP�h�B�������A ��r� Ŗ���^�^�A*KZ�S^�2�:?.y�j����{QfO���+�^k��>�~�w9���� �0�/ҾN���{{��A]{��pE��w7�6
�T��e*��W	��,l��m�+a��~�u��0�_ý� \�����a���p��_������"�C"��bO�7�vf�o8��iS��84��5���D�f;_=���&A�3/�c4�R��I"ٚ�zTE�̠��!�n@! ��8�2��.6��v�3�E�[%��ܫ���d%�@���k���k�$
���)��S�(C�d�2�|Nt���7n���	�nL&[I�M�H�NL��Sn�M@�.L�l7��u<0u`2Mz��p�t�@��������4�k����^`�`���Uz#�Z~p��e����=x�h���qm��z([�N�xk�HaA�i���N��J�k?'E�b�����c����FP�Np�~N�~����BR��?�}z,��T�!�l�B�!�~�O.�3�;U ��ʼ����-�5�ص!%*� d@�x����c�n@�'Aa���Ĳ�����.�2���\�D/aHz&�+kVeH(19n�H����K�|x��2�����ܙ�B������0�}�� i�m��;�����ޝ�D&�=�ǧ�LQ� k6nr\��J8Ľ\��k���D7b$w��%$q�p�z�}��
D�3��(3�D�y)ҩP!�`G��LRo(� �۹L�Y�#��f�;�c_�G���q���	A��
֎�Jk���e� ] �[�����9�by��IEu�d�FY�����?���a��Xֈ�H�:�y?���,4��n�ߤ�T����D�xQ��n#�[G\�e��O�̀��IN�L�,6���?9:e�7���y �#�����FAVwS0^�߈8��F|Ҳ�߈8���2��GP�#��#D�v�f$qm=��B;����� ��F��ٶNI4l��q���Gx�ơ/���BH���l҈A r�T^�q2�u��X���2-׿"_U !��L�F�.Oʱ,.�i�0��c��b�		#�?͡�D� aF�ǽI8GVB�D�X�s6B��sVJ)BZ->2���
3Z��-�iT0������!���Ͽ???�{�P            x������ � �      �     x�u�[n�0E�����e���
f��(F����H��Vȶ� �8�w? p�R S+.P:�u��g��~"����P��������UZGH�ڤG ��:���� o� J���y�7w~�{�̟K��;:PÈ��C(�t��h�<����,��� |�*ځ�d�UP���]R��j+v]�*G��6Dm���zX1A�����¶&�^�kK�����ΉĤ����Ƹ�S�D�oGs�e��{g{}_�����[      �      x��ZɎ�=��"1'	鮽�dpH�2G����t%{����]]7��>�7C7N��_dmY��xMK���b�r�`bٖ�񣉍�Y�Lڟ缨K��%�~�=�`�7�ؖ�e��!"�C\�U*��m[?f� �����T�!dt���ں�:�gk�(�~�Ŝ��d�KQ��T�E#�{�Y)r^�bz��<��-���2ip��Z���]�)���wK�{���{�\@���a�b�2������P�-��^h�?kQ��~�~b��ά�l�x5��R����#�����0�U���</j��������L�8�Bm�J-X��ky��3Ş�4�Y��|*3�d��T���
�f��V:�D��zw�xw�7�,� !8v�ď��Z��v�N�Blϳ��=\ر-���lq��lE�_���رC2�Ƚ_�E�64]+4�Ď=���9v`���4��΃�yL(I�?��_J�QL%�|�W���w���������W
�8ǔ"�2�[s�*�wxL��с���':"�#���:b\9tL�}t'�9/�k%���q���: \����Q�sr݊%�E	�����#[�=b�F�����#�#R֪V����#�H\���d���n��� �7	�i�x��jGv�p)H����v��Y�r$��-�<�E��ۿ	U�*0,����v�KG�Ն��7p∁��]�����ަ���FmW���Ղ盢t�U�׉Z�D�P���dCN�$�K�.xM,�B1�&)-�NwDg����bN���Xs�v��7�q�Q�,�����m��ur�A�VԘ4�����<�.��h=g<a+��@�ʏ2K�FY"���T�C�,�[��OZ��`���Ս�yZ�ղ��P�xT/9��'�}yQ0�G9N;�T�.q��DW��m���Wac��<��bs��iݡ<�y�^��K��]��>9�g���7j�K�ދ\QUI^���؍����򕢻'd�ӛ��c\`��h��4tX�fMh���!���,Ɠ}�O���R��~�:,z�->m�Pg S�F�{ы%
t���v�5g�nD��bZ�����U~fō^���z���3�dg�*aW"J�3c���N(��G{a�� �
VJ6��\���P��G��8�U	A�O\�����0
��]�p�s���BݽHL�:$) I��#x�?H��Wh~���,���9�4m��r�.Q��jߦ�%_T72��;���@BP�zZ����k�-�%3�A�gË�b#<{�`8�Qh����������J2d�,g�r���Nx��(��]��%�xݽ��!��K8Q<8eZ�kY.:��h\bh���Eڰ�4�m˥�����n�?��_v˳$��.�qjX��~��MɵqE�ҥ���ˮ7\��dĮUk����ڣ��Q��]JU���]�5�@#�a#���(
�}�����,��(�q�	��p�xD.��ws��}v�@t��c*vĠ����f@}������ �Ji���70�@�W2o.rZQ��oP��{�yΧ�3WՍ]������ָk��J�$ǖG>{�e$Y��|y��v�6j��{������v"�x�3�hP��5ՑS�H*u���.�U^�~���E�e�g����#g��k�N�[��J�#�Gՠ��}x�&�Ù	4�4.�]�4[5T���=����LW"�.`���\KE�5��o����3SIJº��>�h�Yԣ(��=��9m�9�:��>H@�^�;�fٓ?��}��y�r4�Dj�D{"����K���OjA�Ro���D�y��*K8;{�R��3b\Z�,9^�St?��� q_�T��rC|�����f�t�G�s��iE=�K���Ș�K��E.��&x�;��I���	�G	!gK���aͳ�@!�P��T���VrGE�5a����F"~��/���rؾg���P��M�yg��*U39���!8�L�貃����?H9mھ�S�as�(o��e��$-�7{5��;~S-J69��T.��f��y��?�	-�J1� �7��V�2����}�N�)��Z��"� �η8%X������=�':g��d�����t8d�@�kw�����(7��!*���4�S��0�
|3|�8����tλ����#qL��j:�y�I%���s-��&�+�S�$�@�H�J/ε*9�`��W(ˉ8VȂ��۬��?�k5%7g���$Ƴ�h���<s��,ɵ�_�I��LŢ@^Du�ZtM���ʷ�ؔap�AL3t����md�(22~/&���8O��|�VB+��x�JGXO�P��w�\��ߔ�쮎�ׄ86�j8�Y`�������eg �5�)��p�w��,x"�Hȯ�i`���2�r��������Q_T!i�#�|dI�ڨo'�`���P?�w�V�ߋc�DvX��9�7)�L���/w�P����UU�j��\j���̴C��ғ�!�E=�\��C<����18KO;�iS_�Y0��Zꑌ	��Ŧ��U�A��Ec��p�>^t��RI#>Y�~9�򝞶�>��آ9�c��/|�O�s�*0'
]gd�|Ö�0�Xj[4�s'�:M�|o��>&�y~�<3V�VD/C;�?�U�K=�t��[\��2�]�oE�i>��_ȧ8C<�Z%8��l�P��K5��[��G��/mg`����8�����J�� !�Ů�~-�����=�G��ȸT7J�Àq�c�W4^|�g5�������xb�<P�Z0��'#Ձw��}L�)=�b��t��t	|j��'�y�PL��>��g�L�̻ldŞ�<�ЋB��J�咽�B�h�'��A�n	�m��R�����΍)�!���+�|
]4��$�lJ#��t�L`�8<r'�sQVs��(���6�$f2	��<$��K'������!)�O�� /J��NCq�������̧UZ�������M&�Z�ߣk��Z:U|zw�țOk1��j�+O\��6|B�ځ�BM?�71Po�Q�D�H�L>���`�Q}I�.���m�'���4�`h���#!�~���e*��$E�}��&�Ů���B�R��b��\?"��z����x�9qœ>�9��#6:�O�Bdh���WCi~�jA4���>�����~t����]��Re�yx�~�>������ߢ��O7���u?;\�}�9�k�������b�m����E*��	�J�ܑ$�z�F��F��<�?�C��ɘ�7���RAj)\6B�t��~V2���kW>�M�t�4���$��*M'>�|�a/:��L�L�k�~�0����yA#;G�Y���X����I��<ۓ6���˧�=��}{��J��#����S=�#9��xRb�7��P�"�m�#hz[.���/� �D���L+����
_�z�����f��"��g�K!)a�_^��H�l�b�Zf�T�G��̏C��x�������ɔ3����xg���BϾ{�<:>����ħ��,:<�zS^o��Q�����Mp���9���u��S�ӫ�)������?_�x>Wyپ��	�w�����o����1�����*�_�ѰU܉��8�n��M�N>5��E-ǐz���al���"����<c�ά	zw�Og�ad�k�L^D�{ϘqvՌ��8B���;��Di��4N%T	�/�_�X��Xm�^-ţ?�45��f����w1�'�*�tR-3��s���� ��f�����
��t>ݑi��14�f���cTТ���Fi��$� �z��G��J�(�驑�j�w�|�Iuf%M')_V����M��*��D���t&�4^(xg�1����݋{�M��Eg��q�r�Ð�<@��v�j�v��w8ă���/o^�\��'�N�o�䊛=�O�L��>�e������Y�WM��}��|��1�Y�R�~R��>�����<n�Gq4���*�ᐔ'�h�	a?�ly���ԭ;�F�X)6�ów�oP�՛��wTY����+$�p�|E�&�P��e7_����� 3��[I0{p� #   /�ɢd��yfz{�
L��3�I����<��o�c?�,      �   �   x�5Q˕E![�b�
h/��:&���0	��*�g�a!yO8t�dA�a.�y0	%JY�sI����no���� �8�!�����V �m��cb/�F��^ ��r"�q"Wc�B��*����ـ#��4f���Թ�r�����5/ggW�8��+�֜O�5ZkNo�_�j�x�}�7�����i�z�y�I�z�޴�5gݤ??�O\�y��j�+��ּ>�5�{�ڳ���q�]���-�;�֜s�}�����y���D���Y�      �      x������ � �      �   l
  x��XM��J]�E�H/��8Y��ch�!�AHh6�:]��*����k=4����`7Î���s�v�4������[�{�]v*�U&���[��Y,V�
�|*��K��T"+�Ur���ys��i��\��|�)�~�\<�F.U��x��2a䂿f]�BI�g��|
���D7�J��^�,��m���;ˇ,\�֊�LU�z2��n�`e��8�����*�^*�R�יHu��>�������t��m�󟉊K�ÛT���M�J�L�aC�_�3:R�ٯD`+yD[A����눅\�%�<���j�x�w�
]��s��!溋@����x�����k�<O
+��?��)��u,���X�~��W*�I��W3�����wS�+	'E�W:ҳ?S��� ��4�Db)�DT��u����K%�������6�䏷F�:�>���|/�*�M:K��1:0���~'��$�Wz��J�\�]N�^�������6.��NxԎ;k�a���Ul��G�in������˚�����R�r��B��cgog�Z)Vgy�Z�ץx�x���\/s~���?8�@�Y�gҬ%�\6١e��jov"�N�����qH��)Qtȟ�8�	�I�}�ɖD�ȟ�\�k��U� 'O���a�ĥ�ߨ�>����g~786NEXY%"��;��-~ނ^ �LjXx�jn�~���H����61@����[\�oxp�wkJ`w����1#�w����3U:3�+>��ޚQ�w@ps���#:������`�6_D�%��� �k7�g_��ǝ_?�w)M�_*S'����̟�򙒱%�gMNN.|���}�R��b9`�S����ţ�B/;����I����b!+ˏHʲ���FD�9�.z�[�tb,Eڒ����?d�K� �O�Ik�U�i��g���<�����Π�.u�3[����d|�N��4�X�0��@o8|�N��JT��3�3�_	#�.���S�����\B��
���+�ԉ���J���a�w�����D�n��>�}g�r��i�x��}t�F���`xO��{�{��$z�����t��p��qs���;n��~ �S13%���L��30�3Z~�K�(��P�U�������cX��-a���b��T���BS8�0������3�c���D�kT��l{�p����TU:%n�k����7BU��b�^��B���I�hc ��B$�5�3�	\v&���MU�/3��ɡB��s_ln�'O౓XD�#�q�=֏�n�ɍ��>�>���z��9�(Ћ��{���,�b ���$�t�;U�*��;��2�d������R�G'��Y)\c}�s�K���R�.t�`�e����&��Y�<Q�������q�c�g�?��[z���;���cS�_�,pD#��S56j��@�&����f& ���gD����T ~����hk4b��>�wn�&S=�t7�'Ů!�&$!��{����v��]J"���Pg��Gf�}�C��:���C�>�4����؃�*��Ed��d��"o���G��!	�UH���Z@W��Ue���{jd�C���n��ٔ���0%�Y�Ϭx=Pyn��^���K��L�v��
����_���g�4��մ�K%�'�TV�2>�{��iĆ;Ӎ�=�=�M+<�MI@�(@a��lm
�`���Wŭ�9�D���f�ޘ�@�h'�?#`�<���\E2���~��/�J-�:]#��AU����� ��u"��NU40�a0u�����F{�̲�r&��TP�;�\_�Z����:��ID�m$����F/1�2m	%�I�NY�ߺ]?�`	���$����<�wB��1F�޶V��XL�*T�S�6l[U�@�h� G����;��b8i��|�L"��:Z�n��j���:���!���@�����)2�(mF������m��`P��0�I�L�xX]v�
)�_��t��"�n��� 䂘���F�9&u����;�_"jS�y���m�Z{P����U�4�M03N=]��]��N��r�������4����r]��?\4��>{�����!�_����8���J�����؅��j"6�� �m�]�x�R�'꾢�5�&
Z�vV`FB��pޝr7C���6lk��m�蕨}�j%��W��k�x�������e��pD���#�?:���<�Qg�A�����;1bm?Zػ�:m�A0U��4���2�zt�������^(T��_�EQn�`x�m��QZ��[A$�%J.Q��ȟ��8��*E=Y!{a��dB�67�;|c%(6_$}LY��P�Z.�Ɲ`�� �3i;t%�P���[5-�6�iM`DP������?'�
L���m�e��~&�>;#�Z+�V����)%f��cFg���	�ӫ�K�� S.��I�|!l!lj9�t�����}I(4��	��v��$Y��X�Mٸaߗ�ő]5{`�N���?�#�/�]5��<����
+��9o���G]ʂ+IԨvdr�`���4n-Z�e�Y����QkG�	��UX�g����޵�*6w�����S��V�?HMT��Y����q�d��      �      x��}Ɏd�����+�M7�[���Л^ע���>܀p���j�[A��]A;e�HI�����P�*��4�6�c4��ŗ�����ϧ������?N�v��8�c�O%�y�<����{5�(���C0N�R��Z-��v�At��,���M|P���ǔ�(}���[�m<m�qܯN��)9
�$3d� �დ"&{c�U:����eu�T�)�;�7a0.�A�b��e�|i,��V�!�����o�����;���X�*aG��.G�յjk��?�]x���tJe&=���Z9xS=�@�RTU\�E����v�,�sɂ��uP\�!8/��c��;Ϋ�������Ad>Ԣ����f58������
S�А���{���V���Ic��q�U�1-BY@*6��o�Bga�P�2�rʚU��P�bl+=W#��^����`��t�vp���{��EgI��x�q�8��Y,5%7� 򐬔��$�����eY�7c8�ty���n#SA��ؐ�utlq�[킭!�Ld�����x,k�3猨���
)�Q~��b
���9���"n����)����53]��ֻAfa����T���e\���2ͣ�І�Ɣh'�X�C͞%����[lB���꽔�5$���t�V+xP{��d.���t��58�����=t#�!F[�ƙQ��!�����57+����Yѫ<�eȒU���i]ve�|�c�����'�w�����L���p7pf��=�
w�a|܏�����f|\��<���).�5���D���Fǔ9N8E6@�PJ48j�����i�5Y�ey=���������M݄�%}y�V\�3N�^FS(��5:5���D4�����p]�����[�������Q"��
�#36Y�He�^���5� 5`^��Ơ�Sp�̘�\U�1�Bږ�1��;<
����L9W�t�RJ�hT��.ǐ�{�k�)�
���BTh\@���Ty\?�^����hj4NnP !��M��͔���2o�2�+�8�D��D���@� ,{���,�0�J�A�i��$��k�Ջ�s̃�n���j8_� Ƒ�MK*y7���<��5ߊ�#L�C�P*��8��b̌q.
ϯ�aB��n��&��
�R��Ae/ ���j�"�c�?>��z����O���S�� 9zG�%�%0A8N�3��x�PWaC�k�B	�P$��a	��H����ti�v-�������Ɇvc����|����'�y>!`c[ ��6])�(�f��ZApM�C�)��>O���z� {��h��Ǔ>C�3L�
S��Tf�$�8��[Ҝ���˛�?�f��Rt	�8|Ch�E�8p9�L���c��^{-!��3h��S��k����{��~|����e��F� �~�AA�QP���i��8��y���%�Cy�-Q� o��r�R�`uf�c��f�獎u+��Q�h�<�<rة&�d�u<�\
�d���c�k�^���^�H�]y��P�5��C���J��k�@�1��0t�5��"�@U%�h��/�u^=>�^��6�bi/��b+�;��!ǨS�J W.ʦ��P��
���IŽ����1�G����Q��2VI����F�����8�*�*4�{�'&	[9Ƞt|Q�'�kY���|,�M/��B=�P )�y�KѼd��.�!��
���
�D���s;^P�V��Ж�����YUN� �B	�X]%H]Cv���n��eF��c%�t؄�ޕ �
)�a Ȁ�"a#u���ۑ�Bw�(��D���>�Q�xM^���EŰ�ۑC����q|��lEws�q� ����2�B!���r��tR��� ����fX�2�0Cm�<�m����f�<3�o����G�e��^��RT�.�i�{-H�X�� ����ca�a�|���M2��M������-#nPN������
 <��aS�+"�B���U�LgE�>�gD��*�bd�		�1vyн�g����N��Dl�T�H�V�U"/�+h���<!V���:������}��)k�����F6��xga��t�N�+ 7��x(��Ɉ!Ñ]A?��l9>�^3�U3�9�EFI�(�� k|���p�X^ E����mL��%������
��N�G�0���I6(�c�k�:�Dj4f)S�԰���!�E4�����($����h'�iW�T� (��qƚrHM��܄��%* vDT���i��S��,���	a��c�<�^{,���[?��A)�O�~&�ȉ[o2��1�GJ<\L�E���R�f�1D�$����i|���9.V�c��������U 2�'C�Q.�0�F�0#B��)�<L�%�}��VK��tv�0��d�@�������,�ȕ��J�UB,A%VEM9��������	�_�p����GJ� ��^�d��!~W�G*�)	)�����(I,��uz�`{����
"g1��éR"0(LQ0u�x:�/�����E`n �`,H���3�L@I�:�5C�ZĘ�-�S���`{��	)�zЁ�^ B@=؅����.�jt��������(z�F�JXg ������Z���AMv(�Gb�q�P�B���P ���{hc{M� �8kH��d�A�6�2�%���4�q���I8'|�@:����&���Z-�.tS�k�� �I�E5�	.�%AvH�dX�W麭R�����6��H�Uc�F0Yo���u�C�d9 �2 1�C�� �T!2�.�n�>��T������`�F�<���K
�TVD����%��z����-@9(70� �v�2�R�A�QY���Kם��Q!n�<����#n
,$�������3�_ޏ/�n�_�fa�a(	�PL���B�nI�p�b}��/?/	;�dݮ�]4>W�%K��zM.9��b��s�0�}#�kF`�Ca �� X�,,��yB�L��������t)g�CCx��`�@��[�bt�h��Zn�q�5wߊ�\��u&&D�h�<x,�p�؆�p��|����q��]��ßd��f]}�
Rw�����{�0L$D-%i���\��;E�W[P�r|��'8�� ہ�7���E!4�����J���i9>C=0G�9���
*A�6WDC��!Y�]�M��8��փ��\em�D�B0��(@H�9E췏;>n��k�YD�0@C�z
QV�$ w��	�;B���kw5�T@=I9t%/*�9�z!M4�-���<W���Z8r���}4�%��&'eM	 \b�O��󽆗,%s5Y��&4`���T=r�}������9��rGvWܧ��!qxkQ;D���z-.��%�/]^�G�pf�؏�Z$�Kl1�UY�����������_ym1]��$�&JarApa J!cv���\4�1�;���^��ӏ���90���2���V�
wF[�bQ9\�5l�����i�~�4��C�VT9�cT�t1�A�������c]��^KDĆW*@\aE%�'D� R��#
���8]^�^c4 �5%=�i��T��'�Q��Z��!�#�v�K�J�R*�f�U<�K�jF����\����ȕ1�u����P4Tz��0KeU�t� �����	��Z���l�)�s1�~<�6���6 lWD�0K7O��ǀqS�m��<��T|��lJ�]���й�p}�(b�8;�[z+�(#��]��Ҝ#4ê!l�"��3��N1.�`��5dv�g
�0���}`"�%�2>7�a�M�j����V+��<�UF<�D���g05�M�|Ʀ*�&L�9(��! `�R�u�8� �!Ajw�3p��2��i�!
�6,=��R�����4Rj�w���;����*ʡǔL��<����y\�
g)b*�����FD����rPZ*�(O�]�&�%�    p�Nco9U�IO$MT�t��n�����`�I9� �2�� ���C�I�S����
B<�δ�H���qL:��6�j'�aqg���3:t1�Sp�T`�1a ��80ei��������V���:E����-pȦdUe -���VsP ����y��b�r�� �1�_����7��q��th4�w��p���
K5$�P� �S�T�C�v����.�� K�*wY�t�G/�2|�P^^�T��e��q�p-ﮩa�� r`�9�IQJE��wAY�v�M��k�5㫡�F(,�!�Bѕ�������@f�]Q��eNy(T�����0�޼� ��.�%HC�/3U��2IL(�
�	d�MIZ�D?5�Ed*��a���#E�p$C��*� =�
�"������pT����9ﮬ	RJJ�#���� �Ǩ�	�Nj�q$��/?�G��
St���j�� ʑ��'f.ʲ����\�]n��]Zc��������0$ Ңj42)�{Oy�����ai�^s-	�+QQ�u �Tz�"0����·�f��i�����Sz��S�8R~��iS"�q��Q����E��r<��\��Km��Z	�E�L���}aŉ�Mg���G�t�Mc6�{�Оr�:"$q����8�؇u��U6ﮬ��H�ˀ�L�^`�4D��t�,�ŞjN����Kk����F�y���:��k`�kD_/T���a�!䑀|w�6����Q�	AJv�@��mx;I\芔��5]OF�3�e�36╡9���)�on�����1��wbK�X�	��%r�N;.����^�e�C�y2+R����ԏeŘI{�6䵃�܌�f�p��58�J�-�^p���<'�-�f�f9\o��HOw1�˔�#�ƛ�\�Dp�Q+NH`ND� �.�vkʻ�r�IRsJ��� �X<`���@��H�/*M��^��%�*���GS�����!jY��"-lH;��|W��B��V�
Z�&w \铆S.�]�>��;��������R�B.�S���W�*�N��-�˘�g�;�j�����r%�K�):����d����aU����k�.�at�ce���zhG�ħ$�c�7�B�+UAX)�TG��B�ftmD���pi�\n���ǀ[D�ac�FQ����Q+P�L�<ɶ˸�U��~t�dp*8���B=K�?��
!�h��:�����Y�T�	"�'���6�3���~ ?�.�)��=��!ʝ'EGl��@}�� �w����{�t()�g��H��p���`S��L�s�;����s�m5h��<�@���M�V�v�����-�<Q��X`��E �:Y���=��.©��P�j���O};\��R��To�Rl|�XK���=��dF9�\�qE[̦(�+|�?���0�q\���)��]�cA�����t������	�tk��Z6�B�wW�ȴt`�!6b�Z[b�,ʀ�<�pمǖ�.��bas���S�+ "6�˛�-��G( j��3��n�p���B!o���?�������f7�������<����	z2�F�<5z�fs��S�;���	Η�?W�����t���Q]m�GS��@��T�HsP?Ls���<�����hxG�,��P5x<E�~�����%�V#����r�܍g�������2g�e��9��������H�����7u�(��� 0�P �K��"�RA�M�^�b��	�%|�'�r.��pl��ʱZ�j5����iwҵ��uW�����R�Z ���o�����&�iNqU&S�.�!"�@A�)�a��R� �Qg�$�g����5=8�	M*D5C�!�>�v ���8���xw)e)ݐpdR��I��P��"���S	;��L ��I�@�� �C��7�
U��"��X�q�����5�ܩ��e�*p=�㸬�.B�e�<��9��s��~&�=���'}���][�����A�����h�uT�sl?(H��iIK����4s����I)J���VD�B�W���fq�yn�d�A��d��CU�C�J��5�8��x�pw=PL�v	Q̑=)��N�G[�
8$��M3��*�����jKF|[�G���pkɻŉ�3|�[f��"�kx�"#��)�ȗA�D�*��.l��>�#�vg�Y�4��W����b��VYB��j�پ�뀨Ч$�+`*����0+����2K�(� j!Z���$�uu�z܏�nӺ나e�a7]��%%�n^����9.Ϋ�Okڠ^��-�c�-5�+�Ex5�K���L�@b��w�y�S��4�w;�g���Ny��@�eZ���#`��fɓI�I*�F����ut�8.Y���v�+P�C�R��B���/�Sd
��M����9���n�+�#@%��\0I��h��S/}�ԝ�Zɚf�e	g@�5.ZB���؟���
��v��Hա28�� e����}��s�O��3��8�ӡ���!oG� �DW��!¡�t�&�����=���wȑ�<BՠH�#�o��g�	��o�<��Kz-:�I�
��
|�%��դ��!x��̒�t��H����to��Nt��/�Y��2���yw��&\@�u�.2@˕�	�9`��e��1r.g��Z�L�yf��F��RX_�h��2{2��F�OBC��vA�x@�	P0co�j��V�l���@� i�qwaCPt�� �a ="p�h�����e�>�f��ˬTΊȥAq�"|Qvx��.�Z�a�'����wG����������|�^&��5Jk��P)�f�	���A4⽣�^�:���vy��v�WH L��װ]O;֝��X~1
�q2�&���j�\��F2-^~ۜ�R��26�4һV��f���0����k$��f:���x�l�o�\AO3�'JղY��s�u�Qʦ�6D~>D��- ���B��l�ǿ��a�e�B��������/$A*��-��e��
�+�����U����\��#����X��qu��$�K��z��|���5���J�_�ז�q��w#27ď�	��8}�\���2ث�cZѸ}�[�>m�TsZW����Dt���&b�*���_�y�}��:B�3wI�k!:E'9�LDB:Ԇٻ�q�������M��v�qo�P�bV���믩<� �G9_��Gl[ӡ�B}3�U����<.�o��p���?���[:+�e��n��&�=
��W���W���p�O�iu��v(��o�Xy��Љ��~lK�k��1�W�v`��RO7T؏���+<&�.�������̰���$��N�����p��%=��&eǪ�Ŷ����b���Ĳ���S�:�~n(;�ʎr�w������}�xD��hH�BY���`�
3�I ��Uy&3�.9���$ e�~����oܭh���px������}8Bn�\s ���·��ϵ�+�My�C:���ϒ��)\����S�y=,�/�y`Ǚ�y����P�V.;<��nX�=�ި�ߞɜ����}��G&i�/�.�Ù�y�l�Q�ͣ���BI�>��hܵ��9sz�	��@�?�����0w�L��:��^NY���!�La����,�\Z�;�|�j�m֎�\_��U~��E]=�4~Zޛ7'j�c�$v��g4hDG@�5�����.lΗ�H=*�+��cxj��4����2�iS��C���1��1;3��p����mٹoFQ�8�����q����Q����Sp�܅��t|Mp�q��2���������m�	``��S��Ԃ��9q���іS��)x}�o8���|~�f�6�֌������>���G�2���n�=�4�#�'`�����}4�� c;¾�N,����ߍ�"�4�Gi�>��i��NCM=�ojc��\����u�>�vf;�:�)����P��\[��&�֚�:�6�x |  Õ�\������ܚ�hDǩ��Q����Vs�u�ķ��O���Ϟ�cC
��������m���v����v�p������nc�
i����[�ۓ��'��>W��&��Ca�\l
����-���u�~j��Lٕ�c�*o����~�@����R�s���+j��^��
*����0�#�s�C��X�\���tIǷ��ɧ'o�?WUБi䑖DW����l�;��{C� ��H������	��[@�-�͗`�@+�M�r�߁p��G��5Mv����@˦��#-�i�v����z:?���yI��N�VxxGzY�Sޚ���2	+����;Ar�vޑn`��w¶�A�q%�ܿ��Z��vv����|�TS��r�z�(�,�=-�Z�<?�a�������\3>%z0���P�/�U>!D!TL���qwk?��?�	����R�iI?�P�ofc���.����ZZ��=v��C�t3�<������KZFC;�"�6t֭�Ԯ#q, D��1�4��`[Z�#�H��`��ylG&���`>5��)��;�Bȹ�����vt���F��N�ڑ�B݆�>�����S�����fG�uؕ�M�'�#�K�>� �NJ��>�$a��请Jޓl����7m==<[��&�[�wdA��(UP��zʥޒ�$�G!����9A��/�}��ё��U��B%R�ݬ#yR`r�j�O�V��ȎP§���n�:�= �s8��d�/\����HM�=IPP~ʼ�}wG
T������;r%��˿�q	ޓ�DpmM��:sޑ�k^���O����|�.��v�.�&S�I`������]K�'�IL��jCgu��w�.�����f>ޑ���)9�q����z�xG��3�1�ܤm�j��-xt$0��熏w�/��0:kn��SB�z�o�K���.�6����I�0;h�Hus��;NVz��ZR�qN¼.��}�����O�G�>���{��/�����lG�ӾY��{���ʴV��;��Bʷ�k��d����0�4~�hl��� ${�m�;
�;R�TOӚ�����yN��m�������l]��Ê�{�>u$:�ά���*�Wm��xtn�ǝ���xώ���b<�<Nn���8h�1�=�LC:N�s�>��ޑ����`==j҃���IG���~�Ώ.���'m�y���YGk����k*ޓj\�)do�f�;��Δ��}����~O���n�oޑ��� ���F|1]��0��4����8o(ծ���@R �L�aEY�}BXo��#I�h�.���[��a�������u�ꄥ����~|���q���T���t��yG�N�8��)_»��,�p;wb�۴g	��a"~�5S!�->��'Q._;��3ůe�����t�;��w}d4�s4l1OD����l?�B�����r�fp�)�tdڨ圞�'B=���ɏ�ݿ��4�.�n��+Ef�����|�赙����q�;F���������߶��4�s����pړ�p#퍣��(�<��DG2qbF@/��Úq�y���t����s�UjY&���̈́�(�D��P�.QiT�foI^Ǎ��Q�-U;/�s�3�����qs�v	SGerp��cI_����)ۣ֔�rDGZP�7+ێS8y9��y��u�n������v\����'~��������iO͵As���ɞ�i�!����o��9�c��]I�������������,�ť?�?6��!<�¡�Zzf�: ;��q�'r��'ץ�oo�r�@?A�Fv������n����xiҭrӭ��A���{�j)�%<��[����t��q�,���b���l����)�Y�Ȣ;�b�|;�A��]�;*v����͞����t��mX�E8�o��ȓLP3�o��;8@��;7�b;_������<�ޗH>L�ّ�W'f�0N��U�T�!zJ���x�Q�d��}^�R�#w����'�/:�`�Lc�w�QL.�}�L����t(��L�I�e��9�s�4��L��੽�vmIS�S�x���yeLd��40��e?��~W��⣾�z- ��A���H�iv��|�|���#�=�Ky�1цw��\h�:tȾJ��o�YH���Ω���:� ���՚�,f��x�{yC��do?��EW.��; ��洿݄	ӓ0��_)A��«-��Ϻr�S���kK���S�ҧ	��˖�К���8���<<���6�#T������Jɞ�{R����~�z�1ýsGM��x4�[����.�UK!?#`�ʍ�����u���y�Լ#�G�71���텰56�Z����h���++���֮��̛&(ԑ-�ҫ�J�� ��zQ�4��L�b�]um�:�S%����]�g
Zu����3��H!���u�Ģ���iQ=W��U�7���DO]$��]čU���`|��]S���%=��[��i��/sfvCw��]���Ϛ7�#{����[��P{*(a����p���zҕ���j^���|��Q5�HM�?vi����:�ۡ��B��O@�#�K���4�����Q��ck��^�w��?)鴞V�w��?�S�6�^̬����?�uܜ�	|��������q�9k�������T�C/�"	?����r1�B�`�����_J��)��o}��t�\x��1��F�j��-i��� ����S��`�<���hsM}f����Gc�-S9V���'&>�*��d�-/.�;��8�\l�qJ���H�w��p�^����'�Rǖ4�'�u
Ժ�+-�o�� ��y0�é�<������Wl�������/��}|�����5��0��o8����M@��o����K��m�ק����Ι���k��P�yz�C����O
��5O޾�~$��_��w^��h���ϴ�w���p��׵�c���~�eSb�\�;����T�Ҭ�Mگij�ؠ<	��~5�^n��.�Ѷw�W�P��V��'����"��"��������=��������g��8݆�ȿ�#��4�\��_ l��?'�)�^W�e�����5�?-�k��`C��_S����)�!�;]b�����OԔw�i�y��ñ��ۦ �R��Z)91!p����������      �   �  x�u�AnKE�1YEV�lǱ�%���HD()Q Eb���Q������+�ʝ�?����^�/?]�>>|���zs�<hضp�����W�a{[�)zh|�Uw'�����oJ�����|<�֏vݗ�k���c]:�g[���s�ޟ���������E����L�<;�g��i>;M��a�`~�q8s���~���4�2=dd���Ιs����4M���1�u�A;����7d�������a|;�����z���_�:�p}�\e��'��Q�nv����"���Q�m}¬M���!S69e�և����2Y�SN�3�>d�&gL����_���M�h��4�ii�F�q��ḧ�f8|U�B�����[�f��L�R���y��KIk&j���xKέHO.�ǭ�)LO[z�gkz������G*婚�YNO3=K��Lυӳ.���������N���z!��eB�;��W�R�t/
 �2�X�6P�� �~���ɷꗾX?���]���9�Wܪ�_��J��
�qkz
�Ӗ���ٚ��*=��i�g)=��YNO3=K��Lυӳ.���������^��
�qkz
�Ӗ���ٚ��*=��i�g)=��YNO3=K��Lυӳ.������|�����zs�zs��=����.�枫��������]\�;^�{�6w�6wqm���ܹ�6�pm�hm��|��A��2a>nMOaz�ҳ0�����JOaz��YJ�fz���L�Rz6�\8=�Rz��YJ��GzEz���JYrA�[������eVW�Ƃ,�2��V-��ZW�ZT�ZQ�ZN����k!��ZE�ZB�Z?O|C�Q.+�ǭ�)LO[z�gkz���������l�g9=��,�g3=NϺ��fz��s�-=oE��0���0=m�Y������S��6z�ҳ����4ӳ����\8=�Rz��YJ�7������?mYS      �   �  x���[n� ���*��y��Ҵ���4"�:�Y�8jQu��I�571��V�%���s�nZ?6����V�z#�����ߞ���K�����6��炏ZjAP����-l.�,����SG@X$�"-����Lh��ӛ�`��-��rN�S�j���y��r�Y3R0<R����>/��7��_�6���d{N��"�NN�A�s���9��k���'X�X�������厯�A)�����^I꬀�{L)��J�k�9�P��m��E�*Ӟa˲�!w6j�-u^�Q�eM q)d���1��:$\K��"�:P�4F��_N�x�No>�/�\��R3�t1}W
n��'��K�cழj`�;�]�1eQ��k+{#�r�)��J-��:?�R˳�4�6���$�B���&���ya�s?�>�
����7a� V�]���oSsHFwcFgQ�t�¡N�ξ�p�� ��A�S��w�W)���\-3pxU+2���>
���&q|��`������7��И� �Zsz�3�H�P���U�<Ɖ����}�"�ǕOȹ���G�HY�y`R�A1��>�n��fPC��N)<�ە�);�s�_���c�v$�{�)�4$
�3Y��g�
]0Yz �4��ŻV��S-c��TCu�c>�/���9�v�6�� /�����P��ne�/�����Z*nz<�j�,���Ə�,#xǠ�������      �   �  x�uT�N�@>{^�s�w���׊��5THɚ8[���E#+��*A�'�Wg�xԕ�9�7��~c�]��d�X�̘K��<���v6�f7�����E��+|�զ�TLHH{�W���y�R����5��� }���=�c6ŵ�=Յi0������X؇}Qv����;�n��;�q!,U��AH�3	0��Զ��=-�k�/+����u�D�Q�J�|��Y�х~P����%|��dO�ֺ��m��J�����ǔv��p����'�R��8vy2�X�R�J�� ��[�̳t���T��^�3s��Xi�����8`QGCt���*��f�<N��=���L�xp�-ʺ��5fQ����!\�*o�����Et;��fcM�}�M��e��S��4<�O���K�����oa�|)D�V$���!D���ͦU=C�czor=q���}�XR[���5q}�M�VSR���"h7h7m��v�k�/��4�l[ᆂ���^~�Ƹ;�+9:R�Պz�O�j�6����N�|��33�
�	�337�?�Y��e��,I N�,��q������ԉ�3���~��]!�����$OƔN� mi�D:�6�F����S��Xj�T���2�+V�Zmڼ�N_���{n^�4�����I�1'Ut�TF��Ԏ'(3��s���z;j�=��C,P/N�x�>��ū-݀_����
�F �Vc�:      �   �   x�Sv��O�I�M,(�TF����db����)'�ɥ�����	���}2�RrR+9a.e����\�rCK�Fd�r@Nb����'�37��YSSs��\ʎ��U���U����} �p�`<�=... ��B�      �   �   x�mQ��0|7Sd���	��T#*�'[T�/?�^M������>%�~P`���DӺ>�+?�Q�W�A�<��ު<���1�����)�jy��	dLֿ�y9�?t~������J}h�Q�
#�
#:On.���TY�%�𯅶���a��v��(�,��#�SĶ��g3��s)-7H��dvB| �9��      �      x��Z]oG�}n����� M�G��aa�cg�(l��X�ȶ�"�M4Ip�oc��������ݼE�_{nuU�I�cٓM���Y��n�{ι��%9?�y���E���oR�N3�s.��F*�Dr���K�J�}璿�p��@i�RR�L�U)���6��L&7��#�n^��}]7�lɆ68c\j��`qr�)2����dS,���}�N������ԭ�W�e��~Y��h�Y��'�*�U�	�\�V��"��#�I��yTz�aqͨ����`"Ӓ)�+�l4a�lk���feQ��KW����=>�6��?��w���GV�>�,וK���Iߖ�Ӕ1�5�@u��˲nj�EgٝU?+�Mq]����k�.��x�)�g�Ve��,��X;�)��/��f1)�4��M__��_�u�M����g�̥*s�WO��zZ\����tK㹌Kc"7X�+�7n�R��I_�����ߤ��F�xS.h�Mq��M/����Вm�t�8&�,ע3�3�2#*3<y^_��ĥO�z��^/��/��y�}�We�v_'_}_V�iў�,�V�U�RѪ��Ͳ�=j�̒��zT�Ձ^�0`�_��ϘJ��jcd���vVTK�l��z}�~3!�e�ՓzY���1+�֝���s,�҉�C�FY.*�&y:s���K�ٴ�%<��U����hSl�+}�^,Z�`�](`}X&c�S��YƑgB���
�2n�g5��N�+�E��p�] �r! ����!��{J�w!;?E���=wM=��M=+V��E۰h.�i]8�1�8@*�.	�F�37Y]9��ܡ%�K�Q��pVڰH�+�3%����e2�>��M�����Gt�S�۷�w��Bǔ���"�w��m����+@F7��
�At�d�ٷ���RL8���
9��B9��s�)�(�%~_L�/�w8,ל�ΙU��U�j䒰*����q��a���M�6��-@h�=���F��my�L ��i�=Bf0��L��N��ZP�O0E���ò��!���\�s�;C�F<�A�h@�>��e�l\Z��n�8��$!M��W����ъ�V�ATL��ؾC��;ct�7����S�~�)������iU"��<?0�X�8Cb��#��<�♕�S�
�x��/��B\�� ��A(H		��)�pK���B^���X�̢l�0+@��W� �7"�{��*�����B���bL2��L�䗐6�(-���p��ӈ������]���ê��k���}=�Kh�s�)l1
P-���Rq�Hp lT�x�S��}��.�.��ߖH�����ZL+l����19�s�v7@.7��FEx�@P�C,I�<���i$I\�K��ż�Y����t஠��B0%x���R��/Os�
�K7�&ii�/&�i! |
^��mQ,ND���&�	��ځ��<�ӘdT �|�̼��A�3�<$v�|u�������'���Q�A���m:q�<�HK��s��۶�*Oz�O�A@��<GۻR�!�K5� �C���ɴn�1�	Pt)�9<@����VQ��BK&PiKZ^D��!���<3���0s�rB�b�;8'H��jY4�B�a��ɔz�><o�q�9O�+*��?6�
�<VΓ[��d���]�ޔ ��~�^�\�?�]u]@wNʯ�[��ОJ�sƓ��@��!�l7�g���.G��̆\��t)������2���Ȁ9B	Ы��iQa��wB0�}Gɠ����e�0@�9N��U��2�)(�匜3X,��d�ؐ��'�H��@u�37(&��rU�=䐈�zO��E��WŨ�����+f�z\��\�IĀ,��[�8����C2�d����-٢�?:����]5-~�˺Z�=����ӥ�
AT�$z���\��2l*A�n\�c��`�C��]�!����� -�s�
؄��ܦ�������Ѧ�"���d�e!�����q�@Z�J�@J^�� xH[�q�������D��"�7yQ_��;dy4-&�+\�Ct�'�}�����y�d 9�-��������H^*��E�ӫN��7�Ӹ3p֦?�V�1q�:�<@ˈY��A��'���2y�+���&,≠�ˠ�ddr��H;�4xuE�Px�x�3��iqț�[n^��b1m�}*�&�-�2BB�`��f����W�Jz����(ӿT�e�\-1��#�����V���o '�����W!���_I C�H��A���Ӥ������뫌P�}E#J0T��L��I�B�\XLP��V���2��g)P]��@�\��U�o�Q��y���B��
��7奡�Ր.F�S7�#���q[���������= E_�Z�A�k�W��cR��
�r�UdQ��9%Q	K��b	m��jZR�Re�*�ќ������ c0K��Ѡ~#��|�l��ΈV0"�9b㘉~72X0PF =���w�)�_��q���n�?}}AFz�L�]�FŎ�4J��z'�����:�D���)<C2lElT�7ؐB����6=�! Y���?5���{��pI����Ө�0��\����@1F�*��L�0G�
NE�>^UnPd����73�u+(�H��C	�,AT�[Qc��d��*_����ހA�r�|ɫ������7�K!��w��+�2岾�!`��c\jA}��� hA,,Cp#�E�dyW��������	��9t�˝${�Fð�2*b�!��Tks�ak�#+pi�e��<��&�">H�䔣�"h��>�Y��I#�r �E�oDi&5ğ�8������IM���飪�}�``2(N��B�qΌ�'=�������ӱ��nh$�@B )�=UT	1T�ɓ�X�l�3�����d�v8���R�̓�Љ�M���1C��Q{�2�D
 N��\1O�P�
Z�26l߅�⢸[�������%�CZЭJd�>���)O��������w9D����f����'�����ʴ���!�Л�7��@���$�.J���z���#��'&�0J�������<��`).����'�����6L�IA�"兆��i(��3�dTא-EH���垀6!a���1T,f1��m�9Y�<[5�ʏk�YoO 9mG0T�I���Ij��L\R���� �8�h�X�ո�~T�<�o?��4ވ� E ��mz�[w+x��x'�,�������S$��u�����Aҭ���XC�@T� �b�H)�l�'��EQA�Ɔ;C��%]SƆb$'�V o�1hGQx]��ɟ�_ȴ�E���)����}Nr��t�K�O�
I�p�_��lVWw��������Y��b������f�/\Y8}�pnB�����_ ���r n�[�<R�ȾӀQVQ��|��5uU�Ǫ�o�Z:M/N�Op�wfy�'64�.���"�"����*�����)�Y�>-���۪h�2}UO߼ٵ1dɁ�m���Q�P����P���A���Q��z:�;ܱ��}�-/E~w˶� ��ks����2�C`@�'��U۸Mg����-��:���~�I}>H�x�F�F��]����Y@S繯��~���f�"lU]���rx�ڄ9Ufio !��
�m�?��־�<d��2Fe!��M������#��c�ܭ�i]�A7��MI�2�F��QΡ��c��bR�I|�(u7��Hh�1�[o�;rT��w��:^���=C�#9��͒�M�oM���d�!�+L�G�K��$������v� �zU�+�nQ6-}�@�"j^BV����-�pq8tx�`O;����׿/��޷u�S��z�+{@8�]3&�N|;(u���Kx_�����(�ɑi�Y߈��!�n�����t�u�.�z�[����>���Y�K�:���jqO��� #-�Qn
B����U����<uӢA����oEu�<���퀤
Yb0�.��!�H���K���	>=j:���k���^�1�,)I  �  ���΂��!K�ҭ�oI�pǚ�[B9b8����1$�Q�"=Dg������=ࣨ��@��&�
q�*���YQ`%94�D%'c,��Ȍ&yDM���v�
�-u�0��l���
(Py�PCzwF��[�֣�5_����ߐ����|�4J�#����':Ù�u�����bS��Û�Ć�Z��=���G��D�g�F�*��<y	7��h��}0��ǽC(��[���O���IW����|��Ũ�Z�{�D�Bĭtk��/�G�L�' �n��do<�ٔ��p��E��h+w]_��]�zo���G=!�t#�]�sq���b
�%?v��O���tQrV^M�zY�~��Ʈ\,[b�}�n^��8g�A�/�3��K�֣�ܽfN�|Eō���mQ S1�1�1�7���8��:B�e�V�H��[��
d^��7�0L�py���A>܎
j�b����)@/w��V��1�q^4��Š��-)��"�i�/P����x[��P��=ܤ\�c���GX�ȉ�����B��?-����������>d���Ǎ�/7�G� :w[0L�Ɲ�)��+՞����xҸE�k��;���2��Ԧ�����\RFL�aE��$�g{q�~�q�m�yv?48��ݬ����M{�K�~�:�} Vc�c͕��nb~|��jS����Y1�B���F���@{ϰv��q[~я�ȥQ{S�]t|.���$���)�QK��C*��n�<v�{�
Y�s��|�!3
�M�ޗH�����X�z|ww��zE�/�S=��~[���a8�{�;��I�ƙD�
���#�ˮ���������=zK�}4Y���4��	½�=V:0zx��RO�beB��� <0#d�C�*��bYY���R���篯��:��gt�7��u;*o?��;Q��k����t��v��ѣ�w,^���J�#�Ќ��ѽ���%�g�j]�5���ׇ�4�=t@t��{�o��vp��H�U�.@B�("F�һ!J�\S�����Y�9���;#������ۿ9�}�|��"4��i�jb�_EP��[\E��}w��ܰ�Ɩ=+l�q}�R#�����o3��=�Z���{�g��l��ڕ�i�q����7����2�����ƦUFOw�M.�ߔ�����%sܒ��'��k���������'���YUN����崌���������� �I�[      �   )   x��K�*OT(�O).I,�/O���'�'W�%r��qqq  �t      �   �  x��XMo�H=˿��&DJ���9y��p'F�ā���"�r�[Ï!�SƘ��y�2��.�?�6�i����}�%ZH��v� ����W�^���4�epጆ�F�ܤ'6��t��v���ߎ�"P����_��z��B$9�����O�LDq!��W�O��4�8ҡ�˯:M���_{w�I��M�Χ׿v�������v���=���A�^�D�I	��$w�,�=���"����v>>��5�?�B-�9MzhӹM"��N���k�6�^��^��v�X$"�S<��û��E��
�('z�}_||�|������8�\M�XBw��et��ؕ6�e�=2�y����h<:><�k���5���:��˷M:*}�^�k���.��ӱ���a����a^�n��>j?��gXP r�z}��:7���
F�|��*�g �o�0<M^�䌝�����_�56ܫ���t�{"��d�N��C&����8ɓ4I�B\#����9	�my��_ 9)��D��C��Ii���ؼ��σ�t�X*钘h�#��J�^�X`�27��z4��u�e�-n��$�ll�iwڍ�+� @�Q!���?�^=�3��J����=�ݫ@H��sʔ��vz�E8��'��o���T���_N���Ϟ��v���H�������>o�OD{5���q|)r���gY,9�ʭ':�sqkc���2��I���n��g�SN��
��_�JF�������k�i>����&�uF �����&��� �@���Z�.��7~xW�K�N�+��周�4Q��G"�9�@;O�O�J������N���xO�{\#�8��ƭ�'�|�E��I�Mݎq����)�X,1�i�_��a��.RwN��Z�Hn���˷�졀���'",�	{+���-c����Y�vx:S�ZHO���i���
Dh��ۨ4+�FR-��1�rN�+�V��*f��S���2r������ cHlvdV�����Ur���3���<��`쭽I��!`u"�H/t ��NH���C*7ˣ0�.����{șW��Ja�Ic�lI��ƾkk����a�&#�>~����\�����}�ECS�}x�����s�������je%o�%���8�͈��wxx�����!�I$���)��:�e��VuF�N�6Ф����&�6���>��QM@�� �́���i�i�,C�y��R7z����_��'fn��|~�����4�Ms��%��h	Z@�@�Tq?�9Wt/@=���Q!�1?!/����o��2b�+�9싊>�b׳c	S�&�Ȓ|� ����T`���<y����V�+�Ӄ�r� ����űFa�M�v�.���n;�v���tx�7��?����|P��*=|��~�.=��q��I>�T�T㱘F^��@M�,�MrYn���7X/��ȶ./Xs���*�̶�/�����O)*���4��`��D���Y!|�X�����Y�e\�j�c�<�	���1�"�Ɯ�킗�ol\�M�[��@���N�VI�z=k��ΧA�s�4h�uQj���lfB�踐�J�Fm b�.k젷˺�Z��O�o0�d���F��u��Ac�2�&[ �!��~_,ù��L@VDF0l�
�a����a��>]%�"�o�.'��P����P&�"hy2�̸��ڟ㳛_bE9/u�Ĕ�^g��t����P�)�N$�9��of����C��(�"��F$ T�߬v���t'���ۥ{�;[R��F��s���,�쭙-=�JKZ����t��ueKo��>�
�B5c�<s����a���_)�|.���H����#�?��|�]��Z�6��c���4+�R ��\�:{Mz�l3�k���L	o�|����N���M�P���A:MYG"��Xq����@BG��8t� �G�kz���; ���?��'X���_��A,��ΰQ>�sY�A=d"W��'�E��+E#�oh��X�g�BM��gs�{�xCͮ:�ab�TŅ��}E8/'�ܦ��ٯ��t���ct�0�e�\��¤)��)�HH0��K�aˊ�!�ɕ5'wʅ+!Gɕ��`��AG������K� f�z���OC�UY1�`ř%��Xae��i�8��6v!U�#�L0���u���QPU}��e�Ƞ�<U&�8OdR���P�xEN�K����/����(S0�?�:�JU+�� �.�9���5���P�va��������w':4�>7;�G�V�UTL�1C����������`ů���א�f����
� �d˝ǭy��%'Z���w�*Ͷ�f[7̶�l���vY'#ww�\I�U�|�I�D��C}��4���d�6.|#��3�L����!�?�n�aa����gѭ���֮*���f���t=ϰ[c�����U��i7x`�SM��1�x��ȼ�)��u˨�y�2ھ��d�{2tg:D~��E��(��}*���7��7�]v}v�O
�A��Z�ݼ�����z�� ���Br��˾x~ttԤG/��/�+���
`�+�Ay�3z�k��o_��B�ը�i<�{����̮����L%�b�&�]���˷{Y6L�9���h�R�C���������%/M�u�Ȩ����)+�W���Ack�I���:�?�w�g���t(&EU�Dlm�7p�ڕ��z��1ԤF�r?�����ݕjbSCע���7w���х�����˷�ց��Mf��:��a���>���.5�)�g}�	�>p3��ygp3רE/��F��%=L��=�a��hт�����[�r~�W*�������n��Z�������J��f&ݤu��Z̅djy���u(/E$;�繁�ڥ�)Z8��n��S��mP߿��|��{�: L�t^�A�m�F4׶qXfW����yka�ՙUTZ��jA�\�ʪ����Ǉ�g�� �����55�H�)@�D�o�'��,ɚ�d���������M      �   �  x��UK��0\K��)�F߻d�gH�1دeֹZ�	�l�M�|zzF  ]`l!~�����U�ѵM(](�B����W8�>��fמ΃>����}����~u��Ul��gl���l���d�?v$o֧:��6ׂ̦�^�i�)�(������ծcW^Έ �#k�Vɖt���A(�hdb��].�	 ��P�LQ�p����D�h0�e��B�DͽyƩwj&%�J4��0�,Se� Ѳ4�؜QBQ1Ԣ�v�E�D��o�j��Đݓ��k/]��ӌa�2kE�w4�J�L�BM[{���JRpsk&��US���C�)�<�!�%^��T��E�[g>i-H�ss��ܴ�TZ۴�����,�d�4U7b:K�Y�@��t�w����TXL��XM�~����iм�h��� ���ř�V 5�����ۆȞ�N J���Y/�HHG��ڽ�u�?5���� 4]'��J���|N�W�Q�:ݩ���d:�[a���:5��g1f4o-Q����vD�È���յt��DF�@����[�wV�����n��V�g�E��������N��'D6=���慁��g�43�'M(>���Y�(��Ro�ī� �.��Ia9F(�H�0w�y27 tw��iw<�Ps���|zp�Bz���V�5 ��|FHS\(�:ܟ?��� ��9      �   �  x���M�%��Ǫ��'�����n��|=1�a��ex�Y���!%V�-Iπ�oP�%���H��B���w�T�?�o?��������r���#�{,�q����M����HX�T�Z�s��]r��'���Q.�)�����??��� Q���73!&�_��-�&de¹��~���[�ߝ��"P|@�e�/��w� �6�u�Ȝ.b�7y��� ^n�B_ .II��%=ϒ��.�p�8�	Jj���L���nQ}��}��~��o?�����`��-|@Q챶�cױ�S��:�V�(H�s0%vmDm5.�&N���j����S��O؅Ǧx]��Ir<��h�/�%%�:����.?�^�^@�x�ȑ��Dq� aSف�&Y1t7��Y+งx�y ;	�z$��k>i�>���˚B��y�O�����$�](��N��9̷����T������`RG`��Wľ��0A��'�cB��_~^]���$������АC�;$�Z�땕�������?R�
Gζ1.3XqS��xH���`,�qE��=�$̸�{P�A��4��ߧ��|W$/`���k�I���/|���>^_;�g�J�Ir-K�����k�L���{7�j��m�U�}�`r,1v�g�QT���6�ը�y�q��D�0E¶�� ���]<${nǦqޔ���	�x����Bx��r�j�q�y�l�w���(*��}GPMy��a;�b�h`UŬ�M�CE�5\�&��fX��M����J�i��|s�ts: �訚�Y[�0�0�|%�o%C���h�,��ǲ�-VI�Q&�< ����H'1,x�l��mZ;l�n�'���n�"�I���E��Xc��&�Z���X�;',:\E�D�vXr�e�i��ʅ�)���i-=/�#Ё�J���z=^k�aD�v/����J�x����5WG��d�q�g�( \�=^�b`�@�M�f�;��6^`'f������j���1 �:w�,�N׺��,N��	*�.�zA�
�	"WGB��%w�O[�����j^Y��Y�%��d�^��Qס2���g:���jw�L'��k�݊��P���΃���Mj��B��2*7��Ҹ�3X�[��[���`�D�2Tl�v޺9*�jƭ@TA��t*��|�_���Z�@(�.��àf�!a�OW̎M��)X	�ϧ$��dd8��c?�52�k�7��3�8�u9�G���o����*f�P*s52����a �e&c��'lt��֓m9M@��Tt��z��7��]y %vF6�Ɨdǘ����>g�̈́��l�
ۢ�#��h��U�0/��:��[���튧�Z/�M�88��,�"B���"��K_@֫�-SO	29��L �ޥTย��U��=HH�:��Ļ�$�Bф�G�>i@j��":Ե�Ϧ���W+Os�8�6C���a����է�$3�ΌA�;��T��d�4[�P�Ei��I�峡���̶
f�"޴Z��Y��QPmeS�HO�-Y��HZ��Y�Hz��� �,Y ŠA��+����c�|"U��Ղ4�}1\���r�\��:�t6Z:��VuR҅|3��m4��`(wx<����LjL+�G�h�J�N��e�����[
�W�\��R�E;�̀j/)���Xnp�֢Im�d26��b�Φ�ɼ{��B����(yW�I�-e|DL;TU1 o^B�Ӓōd�q�*�e�a}��Du�n�d�4��)Ƶ��7�3�N*SL����K!�L/Iwi��W�ڙU�jdj��.,MA�퍩%�����69��dFJ#�M�"V6�t$��Yp�	���J�T*���k����b𙍩�~������[0�R_e���r�YR`��&�`��k:�44�:����ɏ<���񖆦�:��n+OjiucF�Qa=
G�0��_W�"MH�#�m��e�Q��OՒF��ZUk��(�籴)��<�<��.69	:��1�z��Glr(~�,�Glvt���f�zĆ"��3��LS����K�� �������eѨM�Q�/L/:�WX���^�^��,�����%��� ��<����'�x����!H����ꯚ�������u�{��i�34�%!��Q��ה�l�JT�Gl�$%��ME�V#6��ϒpF��3��Y�*���s��9�&>C��uq�J3��?��_��"�p{��Q�/�Z��r����N      �   �   x�m�э�0D��bV��@W��_���UN�(�4πgl��/l��g�&����Ҕ
͡@k̯�ܺA������u��bV�^�u��w1�����n� �Pr�e�  ��	0�=g�@j�� p���lٖc����">T���i���q"4�/��.�uW"�uC�S�BP��j+�m
�|��f���0��lI�s���������s�j���6m<{�@��}�!}0;V�'��뺮_G�jp      �      x��ZKs�>�b�'��V���=�Dɒ#Z2K��*U.�b���C(�ͪ����R���_�v����\L�����ӏ�{�yMMF^O��9�ښ�s��٨`횑�̪��嚍�(�F�d2���#&/�*3F�������˲e��)#y(�ƨ�o�FS��;�&�����V��Y�+2݀1d�5|G�y�ZR�n@^!8Y4�^�(�S9k��ZM��t-��#Wm� 2[�!$���yǖP��o�Eu+V���38xOp
��w+�q?Z^��~�~$�} �bCX3o�Z��������KNY�s�j���feղ��.�ƓQ0�8�Bn�	�C������T�$O�k�Ncx9#B��SY�z*���{�H)��@ўȡ�}�}#G�%���O������7��7��;�����:cC�=]�iFG`t�3z���Z��`Ӿ�9��g�� >L����y�$��(S{�^�G/�$�	x��9ۣ���O���lo��Ѥ��[
^`��_��W�}��}��v��]�6��n�����uCN���0��#W}�*U�T�����U�FM��0�=�t�u��f����u��+�%MU7	���O�u��-�{C2i�Ib�ꇾSE��*�yN�9����Lc46�'i-[���/��.�� P,"P����/8(���@e����/��ӄ7(d!hw��MΠ��n�O���\��?���)EuЕC�^ү,d�=��{9�����7mL���&4i�r�E�7^WVn���9W%[g��)��@g�<m0�gl��k�h����^oD�>�$�U�V7�R�[Đr�fp�y��py��}(_a��c��ȁ��⽀�_��#�H5#�8�����@A	�s&>��/��/*�r�*<���o1^f�S����T�6#�YZ�C|��y���3���˪�����y�؂�r��H��s$iBw���0vcΊ��ܲ���!:1�]�(��ϭ�R�q(-���OTw~-笆~^J$��q�Ӊa�;^�E=/%
ؙzw��;�ܭ��$h�����'�,%�N:�O,g���_ۅJ8���FrT���(�ϗ0��7 We��Ny�|���?��kYUv洂�R-0�&���\��K��+��
X��h{,�)�J���4��lC��%t�uk�#$wK#@��0��qћR�iꂕ2�a��%o��:���C��a�d��a�ҿ��q�A��n<��e�8��KhԻ-��g�[4S?
v�@�G��F��e�����2 @y:aB5�ZR�2�Hu���
��nCM��<��~�Ym�(ɍX="�Oϝ�Bh�� � K4Yǻ�������ᯰ�@!�5�Z��S�F�10�����FO ��q�ecu�������ܰ"˱Ž�K��仝͞,�%��8�DN���s]a~�w������vO��@�&I�Y��K!���K�Fn��h�5t$���g.��#d�ZK@�:� [��HwEL�z{ �~��8� ���4�@Z8�L��:m���I�DB��q�a���@�p�R�:J�@̉q�c��*���>/���U3|�H�&Hf7���Йz0v��q������S �;����Sp9��mO~ ��%>��8��My�F=�b�w�����8�DH�^"�c��U���ds��L/1�c���Z�o��W+��L{x����O7���j������Ԛ0�U5�ț���	}�B���^����%�ٴ�,�>���u��B���jp�u�9�h�Ք�߆�N~l�K���B� ����<.�B�{�<�e	c��b�9ߓ��VVb��u�Q�������kY7E���s�c|�A0φ=��*�4�K#J�,2c �A4�<�ȶ
�����!y�kZ5z����k�/�7%�6�˄�:=S�䘖y_��KA�Úsz!��̫iS��_�~�$�B�w�l�GN:�%tǞb�>I��a]���q�Wr)s9`ܦ'x�c��tx�(���@�/�ڜ`j��N#x�C0���F?1)�;^,�-/e+s����L���S�7
�1��S��Stҿ�.!Aj��`��R�1APŪT�:0��8dk@��x�U�"�zi�j��D�0��� V��P'��0��7��b���Z���tG�(xi����f�[fk
�%J��q���kl2;g�&`�+ve 	L�*�/� �`.w�������Ըs�L)X�VТ����.�\���Ny��8N�����̷Y�2�
}U^��EM��+~x	�	��Ԋ3M�W��,D���E����4�1 �N�^��{b��p>Q�S +��������X�p��ym/�@��zc��'���Ϸ!�|��c��#�ZJ{�`_wx	e*ޓQ6�*#n�N1�\��a�.���.�ՠ\�G��ɽ�����X������
Y$Ṙ������IR�H#_6-o�jo)�_6u���	NX�U�$�b]�4�j���y�	6�&�F�W��םc�"�r��iNtd�)@2���s\d�*	�Mh��}aW�+�����>�lT�iz�U��W�o�)��Ofu���m�D�	0+��>��M��4+G'ʬM�ЮgOB��� :
�Ū�p��)[��	23�'7�oIԏ�M���S�t��ƃW-�L(��&tj}�E�=c���O@��	P��Z��XqlC&9��� av�t=��qp hV�i2�j�Ćvϱ�w�V���p�ƞ�o��딼��pA��g��_uͻ�Nzs.��26a�ՠ�(�kN� |t��8�Dzh�CEԄ
n_�{��'/6sg95���X3+���+1�8J�ie_�	 \���8`�����/j��{%FMH�}��֜]����<S�8��157���~DY��0�f9#3\��f�&5���{����ۋ�]��Գ�^�uW3j�ݛL��1(w�M&��;b���;��;���}�=�o�~��v&�Y�7���`�2�-7_8!�!�k���/+{�����5��n$�-6�c�	(�<5+G	�Ӂ�P+ �1����2�@N�X!�-F�%��f�$=��U�~�ә��*�	H���w`gAHw�EwE��w,k��z���ĭ�E7�Wb1�:���W`5=~Ų�G�4�B*��rF����NE6���X�B��̤s��!��䩅l//YŶ_ȕX.eQ�iCH}����(���L�3g�OmPyj'�cBs�*|Ų����3�3<xu�!���6V�sqO�s�M'0ąZ�}A���By8�2�P��`�^۲X�j�X�#@�C��3�M��R:��� *�-�i֑}�{/��<�S^��$�\����n���
cY|@���'5^��-�sf��[r6Psvl9J���_j�Q���?�9�Tdlq��i1�s�%ݚ�lɕ�@��g�f��2P/�Wr^H/��a�KA2n;cM��C,�Ț��V�TOjM1����W 
�M�0��;N��0A��ǮE��y��LH}+3�_hQ���c��ݧٽ��!�R�OF�M�Z= �H��Q����*��w�##�l���C���}��V4�'�%>Bҳ%�Wϧf��[�'��7��jD�닧>}�tF�E�3Y����	��(԰�*4��9/���b��RP�f~ČDKC��K�NjS��罠8�9)�5%"��[�@b�Y˺U��c��0�/,� �D���N��֏�Q$�Y����Ų~�v"w�ث,=�O�v�e���S�� �x�Z�NPt$��y>�[�Z���͠ԣ�̰�5���K�a_0(n%�-8��@=����e�ݪ�G���ws�ż�%�8� 8���a������k�d�Ѧݠ"sq��6���:{�'^��3�@���?�t:�崒N.IH�8tJ͂�/7�w��v��!�sh�!��]�R�2�?$I�\�������q�����/����'�`:����6�p�H�ö��ۏw��vGG8y ��-%�v�emd�w����$�'�^��b-��2T�y��r}�GCo��45�� x   �9�E�*�M����l��R#!Kz^n7+�_����Co��J�6��j�݈u���}n�VQ��]��sw��Ơz�IҮuO1��?^��)>C�nN�e���>�8*�)�D������ Lu�      �   	  x�5�ە!�!�=�0��[2�׍�Θ���S��%֤��j!�җ��c�@�2�6�K��ܲ��P���S+K/E,�9u�&n�C�Y�w��Go��G{SD4���Ɛ襻�,͌���o�O�.{\��:'��q�s����F2#��St#��y�m]M�U+�k�j�;��~�����/]L<�w�G:�7��$�<�g/]����?ɥj�'|����/`?���%ly�#�;:ﾄ/��7�<��_2/�<�6�y�3������\             x������ � �         l
  x��XM��J]�E�H/��8Y��ch�!�AHh6�:]��*����k=4����`7Î���s�v�4������[�{�]v*�U&���[��Y,V�
�|*��K��T"+�Ur���ys��i��\��|�)�~�\<�F.U��x��2a䂿f]�BI�g��|
���D7�J��^�,��m���;ˇ,\�֊�LU�z2��n�`e��8�����*�^*�R�יHu��>�������t��m�󟉊K�ÛT���M�J�L�aC�_�3:R�ٯD`+yD[A����눅\�%�<���j�x�w�
]��s��!溋@����x�����k�<O
+��?��)��u,���X�~��W*�I��W3�����wS�+	'E�W:ҳ?S��� ��4�Db)�DT��u����K%�������6�䏷F�:�>���|/�*�M:K��1:0���~'��$�Wz��J�\�]N�^�������6.��NxԎ;k�a���Ul��G�in������˚�����R�r��B��cgog�Z)Vgy�Z�ץx�x���\/s~���?8�@�Y�gҬ%�\6١e��jov"�N�����qH��)Qtȟ�8�	�I�}�ɖD�ȟ�\�k��U� 'O���a�ĥ�ߨ�>����g~786NEXY%"��;��-~ނ^ �LjXx�jn�~���H����61@����[\�oxp�wkJ`w����1#�w����3U:3�+>��ޚQ�w@ps���#:������`�6_D�%��� �k7�g_��ǝ_?�w)M�_*S'����̟�򙒱%�gMNN.|���}�R��b9`�S����ţ�B/;����I����b!+ˏHʲ���FD�9�.z�[�tb,Eڒ����?d�K� �O�Ik�U�i��g���<�����Π�.u�3[����d|�N��4�X�0��@o8|�N��JT��3�3�_	#�.���S�����\B��
���+�ԉ���J���a�w�����D�n��>�}g�r��i�x��}t�F���`xO��{�{��$z�����t��p��qs���;n��~ �S13%���L��30�3Z~�K�(��P�U�������cX��-a���b��T���BS8�0������3�c���D�kT��l{�p����TU:%n�k����7BU��b�^��B���I�hc ��B$�5�3�	\v&���MU�/3��ɡB��s_ln�'O౓XD�#�q�=֏�n�ɍ��>�>���z��9�(Ћ��{���,�b ���$�t�;U�*��;��2�d������R�G'��Y)\c}�s�K���R�.t�`�e����&��Y�<Q�������q�c�g�?��[z���;���cS�_�,pD#��S56j��@�&����f& ���gD����T ~����hk4b��>�wn�&S=�t7�'Ů!�&$!��{����v��]J"���Pg��Gf�}�C��:���C�>�4����؃�*��Ed��d��"o���G��!	�UH���Z@W��Ue���{jd�C���n��ٔ���0%�Y�Ϭx=Pyn��^���K��L�v��
����_���g�4��մ�K%�'�TV�2>�{��iĆ;Ӎ�=�=�M+<�MI@�(@a��lm
�`���Wŭ�9�D���f�ޘ�@�h'�?#`�<���\E2���~��/�J-�:]#��AU����� ��u"��NU40�a0u�����F{�̲�r&��TP�;�\_�Z����:��ID�m$����F/1�2m	%�I�NY�ߺ]?�`	���$����<�wB��1F�޶V��XL�*T�S�6l[U�@�h� G����;��b8i��|�L"��:Z�n��j���:���!���@�����)2�(mF������m��`P��0�I�L�xX]v�
)�_��t��"�n��� 䂘���F�9&u����;�_"jS�y���m�Z{P����U�4�M03N=]��]��N��r�������4����r]��?\4��>{�����!�_����8���J�����؅��j"6�� �m�]�x�R�'꾢�5�&
Z�vV`FB��pޝr7C���6lk��m�蕨}�j%��W��k�x�������e��pD���#�?:���<�Qg�A�����;1bm?Zػ�:m�A0U��4���2�zt�������^(T��_�EQn�`x�m��QZ��[A$�%J.Q��ȟ��8��*E=Y!{a��dB�67�;|c%(6_$}LY��P�Z.�Ɲ`�� �3i;t%�P���[5-�6�iM`DP������?'�
L���m�e��~&�>;#�Z+�V����)%f��cFg���	�ӫ�K�� S.��I�|!l!lj9�t�����}I(4��	��v��$Y��X�Mٸaߗ�ő]5{`�N���?�#�/�]5��<����
+��9o���G]ʂ+IԨvdr�`���4n-Z�e�Y����QkG�	��UX�g����޵�*6w�����S��V�?HMT��Y����q�d��            x��}Ɏd�����+�M7�[���Л^ע���>܀p���j�[A��]A;e�HI�����P�*��4�6�c4��ŗ�����ϧ������?N�v��8�c�O%�y�<����{5�(���C0N�R��Z-��v�At��,���M|P���ǔ�(}���[�m<m�qܯN��)9
�$3d� �დ"&{c�U:����eu�T�)�;�7a0.�A�b��e�|i,��V�!�����o�����;���X�*aG��.G�յjk��?�]x���tJe&=���Z9xS=�@�RTU\�E����v�,�sɂ��uP\�!8/��c��;Ϋ�������Ad>Ԣ����f58������
S�А���{���V���Ic��q�U�1-BY@*6��o�Bga�P�2�rʚU��P�bl+=W#��^����`��t�vp���{��EgI��x�q�8��Y,5%7� 򐬔��$�����eY�7c8�ty���n#SA��ؐ�utlq�[킭!�Ld�����x,k�3猨���
)�Q~��b
���9���"n����)����53]��ֻAfa����T���e\���2ͣ�І�Ɣh'�X�C͞%����[lB���꽔�5$���t�V+xP{��d.���t��58�����=t#�!F[�ƙQ��!�����57+����Yѫ<�eȒU���i]ve�|�c�����'�w�����L���p7pf��=�
w�a|܏�����f|\��<���).�5���D���Fǔ9N8E6@�PJ48j�����i�5Y�ey=���������M݄�%}y�V\�3N�^FS(��5:5���D4�����p]�����[�������Q"��
�#36Y�He�^���5� 5`^��Ơ�Sp�̘�\U�1�Bږ�1��;<
����L9W�t�RJ�hT��.ǐ�{�k�)�
���BTh\@���Ty\?�^����hj4NnP !��M��͔���2o�2�+�8�D��D���@� ,{���,�0�J�A�i��$��k�Ջ�s̃�n���j8_� Ƒ�MK*y7���<��5ߊ�#L�C�P*��8��b̌q.
ϯ�aB��n��&��
�R��Ae/ ���j�"�c�?>��z����O���S�� 9zG�%�%0A8N�3��x�PWaC�k�B	�P$��a	��H����ti�v-�������Ɇvc����|����'�y>!`c[ ��6])�(�f��ZApM�C�)��>O���z� {��h��Ǔ>C�3L�
S��Tf�$�8��[Ҝ���˛�?�f��Rt	�8|Ch�E�8p9�L���c��^{-!��3h��S��k����{��~|����e��F� �~�AA�QP���i��8��y���%�Cy�-Q� o��r�R�`uf�c��f�獎u+��Q�h�<�<rة&�d�u<�\
�d���c�k�^���^�H�]y��P�5��C���J��k�@�1��0t�5��"�@U%�h��/�u^=>�^��6�bi/��b+�;��!ǨS�J W.ʦ��P��
���IŽ����1�G����Q��2VI����F�����8�*�*4�{�'&	[9Ƞt|Q�'�kY���|,�M/��B=�P )�y�KѼd��.�!��
���
�D���s;^P�V��Ж�����YUN� �B	�X]%H]Cv���n��eF��c%�t؄�ޕ �
)�a Ȁ�"a#u���ۑ�Bw�(��D���>�Q�xM^���EŰ�ۑC����q|��lEws�q� ����2�B!���r��tR��� ����fX�2�0Cm�<�m����f�<3�o����G�e��^��RT�.�i�{-H�X�� ����ca�a�|���M2��M������-#nPN������
 <��aS�+"�B���U�LgE�>�gD��*�bd�		�1vyн�g����N��Dl�T�H�V�U"/�+h���<!V���:������}��)k�����F6��xga��t�N�+ 7��x(��Ɉ!Ñ]A?��l9>�^3�U3�9�EFI�(�� k|���p�X^ E����mL��%������
��N�G�0���I6(�c�k�:�Dj4f)S�԰���!�E4�����($����h'�iW�T� (��qƚrHM��܄��%* vDT���i��S��,���	a��c�<�^{,���[?��A)�O�~&�ȉ[o2��1�GJ<\L�E���R�f�1D�$����i|���9.V�c��������U 2�'C�Q.�0�F�0#B��)�<L�%�}��VK��tv�0��d�@�������,�ȕ��J�UB,A%VEM9��������	�_�p����GJ� ��^�d��!~W�G*�)	)�����(I,��uz�`{����
"g1��éR"0(LQ0u�x:�/�����E`n �`,H���3�L@I�:�5C�ZĘ�-�S���`{��	)�zЁ�^ B@=؅����.�jt��������(z�F�JXg ������Z���AMv(�Gb�q�P�B���P ���{hc{M� �8kH��d�A�6�2�%���4�q���I8'|�@:����&���Z-�.tS�k�� �I�E5�	.�%AvH�dX�W麭R�����6��H�Uc�F0Yo���u�C�d9 �2 1�C�� �T!2�.�n�>��T������`�F�<���K
�TVD����%��z����-@9(70� �v�2�R�A�QY���Kם��Q!n�<����#n
,$�������3�_ޏ/�n�_�fa�a(	�PL���B�nI�p�b}��/?/	;�dݮ�]4>W�%K��zM.9��b��s�0�}#�kF`�Ca �� X�,,��yB�L��������t)g�CCx��`�@��[�bt�h��Zn�q�5wߊ�\��u&&D�h�<x,�p�؆�p��|����q��]��ßd��f]}�
Rw�����{�0L$D-%i���\��;E�W[P�r|��'8�� ہ�7���E!4�����J���i9>C=0G�9���
*A�6WDC��!Y�]�M��8��փ��\em�D�B0��(@H�9E췏;>n��k�YD�0@C�z
QV�$ w��	�;B���kw5�T@=I9t%/*�9�z!M4�-���<W���Z8r���}4�%��&'eM	 \b�O��󽆗,%s5Y��&4`���T=r�}������9��rGvWܧ��!qxkQ;D���z-.��%�/]^�G�pf�؏�Z$�Kl1�UY�����������_ym1]��$�&JarApa J!cv���\4�1�;���^��ӏ���90���2���V�
wF[�bQ9\�5l�����i�~�4��C�VT9�cT�t1�A�������c]��^KDĆW*@\aE%�'D� R��#
���8]^�^c4 �5%=�i��T��'�Q��Z��!�#�v�K�J�R*�f�U<�K�jF����\����ȕ1�u����P4Tz��0KeU�t� �����	��Z���l�)�s1�~<�6���6 lWD�0K7O��ǀqS�m��<��T|��lJ�]���й�p}�(b�8;�[z+�(#��]��Ҝ#4ê!l�"��3��N1.�`��5dv�g
�0���}`"�%�2>7�a�M�j����V+��<�UF<�D���g05�M�|Ʀ*�&L�9(��! `�R�u�8� �!Ajw�3p��2��i�!
�6,=��R�����4Rj�w���;����*ʡǔL��<����y\�
g)b*�����FD����rPZ*�(O�]�&�%�    p�Nco9U�IO$MT�t��n�����`�I9� �2�� ���C�I�S����
B<�δ�H���qL:��6�j'�aqg���3:t1�Sp�T`�1a ��80ei��������V���:E����-pȦdUe -���VsP ����y��b�r�� �1�_����7��q��th4�w��p���
K5$�P� �S�T�C�v����.�� K�*wY�t�G/�2|�P^^�T��e��q�p-ﮩa�� r`�9�IQJE��wAY�v�M��k�5㫡�F(,�!�Bѕ�������@f�]Q��eNy(T�����0�޼� ��.�%HC�/3U��2IL(�
�	d�MIZ�D?5�Ed*��a���#E�p$C��*� =�
�"������pT����9ﮬ	RJJ�#���� �Ǩ�	�Nj�q$��/?�G��
St���j�� ʑ��'f.ʲ����\�]n��]Zc��������0$ Ңj42)�{Oy�����ai�^s-	�+QQ�u �Tz�"0����·�f��i�����Sz��S�8R~��iS"�q��Q����E��r<��\��Km��Z	�E�L���}aŉ�Mg���G�t�Mc6�{�Оr�:"$q����8�؇u��U6ﮬ��H�ˀ�L�^`�4D��t�,�ŞjN����Kk����F�y���:��k`�kD_/T���a�!䑀|w�6����Q�	AJv�@��mx;I\芔��5]OF�3�e�36╡9���)�on�����1��wbK�X�	��%r�N;.����^�e�C�y2+R����ԏeŘI{�6䵃�܌�f�p��58�J�-�^p���<'�-�f�f9\o��HOw1�˔�#�ƛ�\�Dp�Q+NH`ND� �.�vkʻ�r�IRsJ��� �X<`���@��H�/*M��^��%�*���GS�����!jY��"-lH;��|W��B��V�
Z�&w \铆S.�]�>��;��������R�B.�S���W�*�N��-�˘�g�;�j�����r%�K�):����d����aU����k�.�at�ce���zhG�ħ$�c�7�B�+UAX)�TG��B�ftmD���pi�\n���ǀ[D�ac�FQ����Q+P�L�<ɶ˸�U��~t�dp*8���B=K�?��
!�h��:�����Y�T�	"�'���6�3���~ ?�.�)��=��!ʝ'EGl��@}�� �w����{�t()�g��H��p���`S��L�s�;����s�m5h��<�@���M�V�v�����-�<Q��X`��E �:Y���=��.©��P�j���O};\��R��To�Rl|�XK���=��dF9�\�qE[̦(�+|�?���0�q\���)��]�cA�����t������	�tk��Z6�B�wW�ȴt`�!6b�Z[b�,ʀ�<�pمǖ�.��bas���S�+ "6�˛�-��G( j��3��n�p���B!o���?�������f7�������<����	z2�F�<5z�fs��S�;���	Η�?W�����t���Q]m�GS��@��T�HsP?Ls���<�����hxG�,��P5x<E�~�����%�V#����r�܍g�������2g�e��9��������H�����7u�(��� 0�P �K��"�RA�M�^�b��	�%|�'�r.��pl��ʱZ�j5����iwҵ��uW�����R�Z ���o�����&�iNqU&S�.�!"�@A�)�a��R� �Qg�$�g����5=8�	M*D5C�!�>�v ���8���xw)e)ݐpdR��I��P��"���S	;��L ��I�@�� �C��7�
U��"��X�q�����5�ܩ��e�*p=�㸬�.B�e�<��9��s��~&�=���'}���][�����A�����h�uT�sl?(H��iIK����4s����I)J���VD�B�W���fq�yn�d�A��d��CU�C�J��5�8��x�pw=PL�v	Q̑=)��N�G[�
8$��M3��*�����jKF|[�G���pkɻŉ�3|�[f��"�kx�"#��)�ȗA�D�*��.l��>�#�vg�Y�4��W����b��VYB��j�پ�뀨Ч$�+`*����0+����2K�(� j!Z���$�uu�z܏�nӺ나e�a7]��%%�n^����9.Ϋ�Okڠ^��-�c�-5�+�Ex5�K���L�@b��w�y�S��4�w;�g���Ny��@�eZ���#`��fɓI�I*�F����ut�8.Y���v�+P�C�R��B���/�Sd
��M����9���n�+�#@%��\0I��h��S/}�ԝ�Zɚf�e	g@�5.ZB���؟���
��v��Hա28�� e����}��s�O��3��8�ӡ���!oG� �DW��!¡�t�&�����=���wȑ�<BՠH�#�o��g�	��o�<��Kz-:�I�
��
|�%��դ��!x��̒�t��H����to��Nt��/�Y��2���yw��&\@�u�.2@˕�	�9`��e��1r.g��Z�L�yf��F��RX_�h��2{2��F�OBC��vA�x@�	P0co�j��V�l���@� i�qwaCPt�� �a ="p�h�����e�>�f��ˬTΊȥAq�"|Qvx��.�Z�a�'����wG����������|�^&��5Jk��P)�f�	���A4⽣�^�:���vy��v�WH L��װ]O;֝��X~1
�q2�&���j�\��F2-^~ۜ�R��26�4һV��f���0����k$��f:���x�l�o�\AO3�'JղY��s�u�Qʦ�6D~>D��- ���B��l�ǿ��a�e�B��������/$A*��-��e��
�+�����U����\��#����X��qu��$�K��z��|���5���J�_�ז�q��w#27ď�	��8}�\���2ث�cZѸ}�[�>m�TsZW����Dt���&b�*���_�y�}��:B�3wI�k!:E'9�LDB:Ԇٻ�q�������M��v�qo�P�bV���믩<� �G9_��Gl[ӡ�B}3�U����<.�o��p���?���[:+�e��n��&�=
��W���W���p�O�iu��v(��o�Xy��Љ��~lK�k��1�W�v`��RO7T؏���+<&�.�������̰���$��N�����p��%=��&eǪ�Ŷ����b���Ĳ���S�:�~n(;�ʎr�w������}�xD��hH�BY���`�
3�I ��Uy&3�.9���$ e�~����oܭh���px������}8Bn�\s ���·��ϵ�+�My�C:���ϒ��)\����S�y=,�/�y`Ǚ�y����P�V.;<��nX�=�ި�ߞɜ����}��G&i�/�.�Ù�y�l�Q�ͣ���BI�>��hܵ��9sz�	��@�?�����0w�L��:��^NY���!�La����,�\Z�;�|�j�m֎�\_��U~��E]=�4~Zޛ7'j�c�$v��g4hDG@�5�����.lΗ�H=*�+��cxj��4����2�iS��C���1��1;3��p����mٹoFQ�8�����q����Q����Sp�܅��t|Mp�q��2���������m�	``��S��Ԃ��9q���іS��)x}�o8���|~�f�6�֌������>���G�2���n�=�4�#�'`�����}4�� c;¾�N,����ߍ�"�4�Gi�>��i��NCM=�ojc��\����u�>�vf;�:�)����P��\[��&�֚�:�6�x |  Õ�\������ܚ�hDǩ��Q����Vs�u�ķ��O���Ϟ�cC
��������m���v����v�p������nc�
i����[�ۓ��'��>W��&��Ca�\l
����-���u�~j��Lٕ�c�*o����~�@����R�s���+j��^��
*����0�#�s�C��X�\���tIǷ��ɧ'o�?WUБi䑖DW����l�;��{C� ��H������	��[@�-�͗`�@+�M�r�߁p��G��5Mv����@˦��#-�i�v����z:?���yI��N�VxxGzY�Sޚ���2	+����;Ar�vޑn`��w¶�A�q%�ܿ��Z��vv����|�TS��r�z�(�,�=-�Z�<?�a�������\3>%z0���P�/�U>!D!TL���qwk?��?�	����R�iI?�P�ofc���.����ZZ��=v��C�t3�<������KZFC;�"�6t֭�Ԯ#q, D��1�4��`[Z�#�H��`��ylG&���`>5��)��;�Bȹ�����vt���F��N�ڑ�B݆�>�����S�����fG�uؕ�M�'�#�K�>� �NJ��>�$a��请Jޓl����7m==<[��&�[�wdA��(UP��zʥޒ�$�G!����9A��/�}��ё��U��B%R�ݬ#yR`r�j�O�V��ȎP§���n�:�= �s8��d�/\����HM�=IPP~ʼ�}wG
T������;r%��˿�q	ޓ�DpmM��:sޑ�k^���O����|�.��v�.�&S�I`������]K�'�IL��jCgu��w�.�����f>ޑ���)9�q����z�xG��3�1�ܤm�j��-xt$0��熏w�/��0:kn��SB�z�o�K���.�6����I�0;h�Hus��;NVz��ZR�qN¼.��}�����O�G�>���{��/�����lG�ӾY��{���ʴV��;��Bʷ�k��d����0�4~�hl��� ${�m�;
�;R�TOӚ�����yN��m�������l]��Ê�{�>u$:�ά���*�Wm��xtn�ǝ���xώ���b<�<Nn���8h�1�=�LC:N�s�>��ޑ����`==j҃���IG���~�Ώ.���'m�y���YGk����k*ޓj\�)do�f�;��Δ��}����~O���n�oޑ��� ���F|1]��0��4����8o(ծ���@R �L�aEY�}BXo��#I�h�.���[��a�������u�ꄥ����~|���q���T���t��yG�N�8��)_»��,�p;wb�۴g	��a"~�5S!�->��'Q._;��3ůe�����t�;��w}d4�s4l1OD����l?�B�����r�fp�)�tdڨ圞�'B=���ɏ�ݿ��4�.�n��+Ef�����|�赙����q�;F���������߶��4�s����pړ�p#퍣��(�<��DG2qbF@/��Úq�y���t����s�UjY&���̈́�(�D��P�.QiT�foI^Ǎ��Q�-U;/�s�3�����qs�v	SGerp��cI_����)ۣ֔�rDGZP�7+ێS8y9��y��u�n������v\����'~��������iO͵As���ɞ�i�!����o��9�c��]I�������������,�ť?�?6��!<�¡�Zzf�: ;��q�'r��'ץ�oo�r�@?A�Fv������n����xiҭrӭ��A���{�j)�%<��[����t��q�,���b���l����)�Y�Ȣ;�b�|;�A��]�;*v����͞����t��mX�E8�o��ȓLP3�o��;8@��;7�b;_������<�ޗH>L�ّ�W'f�0N��U�T�!zJ���x�Q�d��}^�R�#w����'�/:�`�Lc�w�QL.�}�L����t(��L�I�e��9�s�4��L��੽�vmIS�S�x���yeLd��40��e?��~W��⣾�z- ��A���H�iv��|�|���#�=�Ky�1цw��\h�:tȾJ��o�YH���Ω���:� ���՚�,f��x�{yC��do?��EW.��; ��洿݄	ӓ0��_)A��«-��Ϻr�S���kK���S�ҧ	��˖�К���8���<<���6�#T������Jɞ�{R����~�z�1ýsGM��x4�[����.�UK!?#`�ʍ�����u���y�Լ#�G�71���텰56�Z����h���++���֮��̛&(ԑ-�ҫ�J�� ��zQ�4��L�b�]um�:�S%����]�g
Zu����3��H!���u�Ģ���iQ=W��U�7���DO]$��]čU���`|��]S���%=��[��i��/sfvCw��]���Ϛ7�#{����[��P{*(a����p���zҕ���j^���|��Q5�HM�?vi����:�ۡ��B��O@�#�K���4�����Q��ck��^�w��?)鴞V�w��?�S�6�^̬����?�uܜ�	|��������q�9k�������T�C/�"	?����r1�B�`�����_J��)��o}��t�\x��1��F�j��-i��� ����S��`�<���hsM}f����Gc�-S9V���'&>�*��d�-/.�;��8�\l�qJ���H�w��p�^����'�Rǖ4�'�u
Ժ�+-�o�� ��y0�é�<������Wl�������/��}|�����5��0��o8����M@��o����K��m�ק����Ι���k��P�yz�C����O
��5O޾�~$��_��w^��h���ϴ�w���p��׵�c���~�eSb�\�;����T�Ҭ�Mگij�ؠ<	��~5�^n��.�Ѷw�W�P��V��'����"��"��������=��������g��8݆�ȿ�#��4�\��_ l��?'�)�^W�e�����5�?-�k��`C��_S����)�!�;]b�����OԔw�i�y��ñ��ۦ �R��Z)91!p����������      �      x������ � �     