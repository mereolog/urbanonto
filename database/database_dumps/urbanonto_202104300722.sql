PGDMP     ;                    y        	   urbanonto    12.1    13.1 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    37727 	   urbanonto    DATABASE     m   CREATE DATABASE urbanonto WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_United States.1252';
    DROP DATABASE urbanonto;
                postgres    false                        2615    37944    ontology    SCHEMA        CREATE SCHEMA ontology;
    DROP SCHEMA ontology;
                postgres    false                        2615    37945    ontology_sources    SCHEMA         CREATE SCHEMA ontology_sources;
    DROP SCHEMA ontology_sources;
                postgres    false            �            1255    37947 
   lastdate()    FUNCTION     �   CREATE FUNCTION ontology.lastdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN    
   
  		NEW.last_date := current_timestamp;
    
        RETURN NEW;
 END;
$$;
 #   DROP FUNCTION ontology.lastdate();
       ontology          postgres    false    4            �            1259    37948 *   topographic_object_function_manifestations    TABLE     #  CREATE TABLE ontology.topographic_object_function_manifestations (
    identifiers integer NOT NULL,
    topographic_object_identifiers integer NOT NULL,
    starts_at date,
    ends_at date,
    function_identifiers integer NOT NULL,
    historical_evidence_identifiers integer NOT NULL
);
 @   DROP TABLE ontology.topographic_object_function_manifestations;
       ontology         heap    postgres    false    4                       1255    37951 8   topographic_object_function_manifestations_filled_func()    FUNCTION       CREATE FUNCTION ontology.topographic_object_function_manifestations_filled_func() RETURNS SETOF ontology.topographic_object_function_manifestations
    LANGUAGE plpgsql
    AS $$

DECLARE
 toi integer;
 i integer;
 filled_count integer;

begin
	EXECUTE 'SELECT max(identifiers) FROM ontology.topographic_object_function_manifestations' INTO i;
	RETURN QUERY SELECT * FROM ontology.topographic_object_function_manifestations;
	-- GET DIAGNOSTICS i = ROW_COUNT;
	FOR toi in
	 SELECT DISTINCT(N.topographic_object_identifiers) FROM ontology.topographic_object_function_manifestations N ORDER BY N.topographic_object_identifiers
	LOOP
	 RETURN QUERY SELECT d.identifiers,d.topographic_object_identifiers,d.starts_at,d.ends_at,d.function_identifiers,d.historical_source_identifiers
	 FROM (
      SELECT	(i + (row_number() over ())::integer) AS identifiers,
				t.topographic_object_identifiers,
				t.ends_at AS starts_at,
				LEAD(t.starts_at) OVER (partition by t.topographic_object_identifiers = toi ORDER BY t.starts_at) AS ends_at,
				t.function_identifiers,
				NULL::integer AS historical_source_identifiers,
				LEAD(t.starts_at) OVER (partition by t.topographic_object_identifiers = toi ORDER BY t.starts_at) - t.ends_at AS diff
	  FROM ontology.topographic_object_function_manifestations t
	  WHERE t.topographic_object_identifiers = toi ORDER BY t.starts_at) d
	 WHERE d.diff > 0;
	GET DIAGNOSTICS filled_count = ROW_COUNT;
	-- raise notice 'i=%',filled_count;
	i := i + filled_count;
	END LOOP;
	RETURN;
END
$$;
 Q   DROP FUNCTION ontology.topographic_object_function_manifestations_filled_func();
       ontology          postgres    false    204    4            �            1259    37952 *   topographic_object_location_manifestations    TABLE     O  CREATE TABLE ontology.topographic_object_location_manifestations (
    identifiers integer NOT NULL,
    topographic_object_identifiers integer NOT NULL,
    starts_at date,
    ends_at date,
    location_identifiers integer NOT NULL,
    historical_evidence_identifiers integer NOT NULL,
    location_link_type_identifiers integer
);
 @   DROP TABLE ontology.topographic_object_location_manifestations;
       ontology         heap    postgres    false    4                       1255    37955 8   topographic_object_location_manifestations_filled_func()    FUNCTION     %  CREATE FUNCTION ontology.topographic_object_location_manifestations_filled_func() RETURNS SETOF ontology.topographic_object_location_manifestations
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
	EXECUTE 'SELECT max(identifiers) FROM ontology.topographic_object_location_manifestations' INTO i;
	RETURN QUERY SELECT * FROM ontology.topographic_object_location_manifestations;
	-- GET DIAGNOSTICS i = ROW_COUNT;
	FOR toi in
	 SELECT DISTINCT(N.topographic_object_identifiers) FROM ontology.topographic_object_location_manifestations N ORDER BY N.topographic_object_identifiers
	LOOP
	 RETURN QUERY SELECT d.identifiers,d.topographic_object_identifiers,d.starts_at,d.ends_at,d.location_identifiers,d.historical_source_identifiers,d.location_link_type_identifiers
	 FROM (
      SELECT	(i + (row_number() over ())::integer) AS identifiers,
				t.topographic_object_identifiers,
				t.ends_at AS starts_at,
				LEAD(t.starts_at) OVER (partition by t.topographic_object_identifiers = toi ORDER BY t.starts_at) AS ends_at,
				t.location_identifiers,
				NULL::integer AS historical_source_identifiers,
				t.location_link_type_identifiers,
				LEAD(t.starts_at) OVER (partition by t.topographic_object_identifiers = toi ORDER BY t.starts_at) - t.ends_at AS diff
	  FROM ontology.topographic_object_location_manifestations t
	  WHERE t.topographic_object_identifiers = toi ORDER BY t.starts_at) d
	 WHERE d.diff > 0;
	GET DIAGNOSTICS filled_count = ROW_COUNT;
	-- raise notice 'i=%',filled_count;
	i := i + filled_count;
	END LOOP;
	RETURN;
END
$$;
 Q   DROP FUNCTION ontology.topographic_object_location_manifestations_filled_func();
       ontology          postgres    false    205    4            �            1259    37956 &   topographic_object_name_manifestations    TABLE     �  CREATE TABLE ontology.topographic_object_name_manifestations (
    identifiers integer NOT NULL,
    topographic_object_identifiers integer NOT NULL,
    starts_at date,
    ends_at date,
    names text NOT NULL,
    historical_evidence_identifiers integer NOT NULL,
    name_link_type_identifiers integer NOT NULL,
    CONSTRAINT topographic_object_name_manifestations_check CHECK ((NOT ((starts_at IS NULL) AND (ends_at IS NULL))))
);
 <   DROP TABLE ontology.topographic_object_name_manifestations;
       ontology         heap    postgres    false    4                       1255    37963 4   topographic_object_name_manifestations_filled_func()    FUNCTION     �  CREATE FUNCTION ontology.topographic_object_name_manifestations_filled_func() RETURNS SETOF ontology.topographic_object_name_manifestations
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
	EXECUTE 'SELECT max(identifiers) FROM ontology.topographic_object_name_manifestations' INTO i;
	RETURN QUERY SELECT * FROM ontology.topographic_object_name_manifestations;
	-- GET DIAGNOSTICS i = ROW_COUNT;
	FOR toi in
	 SELECT DISTINCT(N.topographic_object_identifiers) FROM ontology.topographic_object_name_manifestations N ORDER BY N.topographic_object_identifiers
	LOOP
	 RETURN QUERY SELECT d.identifiers,d.topographic_object_identifiers,d.starts_at,d.ends_at,d.names,d.historical_source_identifiers,d.name_link_type_identifiers
	 FROM (
      SELECT	(i + (row_number() over ())::integer) AS identifiers,
				t.topographic_object_identifiers,
				t.ends_at AS starts_at,
				LEAD(t.starts_at) OVER (partition by t.topographic_object_identifiers = toi ORDER BY t.starts_at) AS ends_at,
				t.names,
				NULL::integer AS historical_source_identifiers,
				t.name_link_type_identifiers,
				LEAD(t.starts_at) OVER (partition by t.topographic_object_identifiers = toi ORDER BY t.starts_at) - t.ends_at AS diff
	  FROM ontology.topographic_object_name_manifestations t
	  WHERE t.topographic_object_identifiers = toi ORDER BY t.starts_at) d
	 WHERE d.diff > 0;
	GET DIAGNOSTICS filled_count = ROW_COUNT;
	-- raise notice 'i=%',filled_count;
	i := i + filled_count;
	END LOOP;
	RETURN;
END
$$;
 M   DROP FUNCTION ontology.topographic_object_name_manifestations_filled_func();
       ontology          postgres    false    206    4            �            1259    37964 &   topographic_object_type_manifestations    TABLE       CREATE TABLE ontology.topographic_object_type_manifestations (
    identifiers integer NOT NULL,
    topographic_object_identifiers integer NOT NULL,
    starts_at date,
    ends_at date,
    type_identifiers integer NOT NULL,
    historical_evidence_identifiers integer NOT NULL
);
 <   DROP TABLE ontology.topographic_object_type_manifestations;
       ontology         heap    postgres    false    4                       1255    37967 4   topographic_object_type_manifestations_filled_func()    FUNCTION     �  CREATE FUNCTION ontology.topographic_object_type_manifestations_filled_func() RETURNS SETOF ontology.topographic_object_type_manifestations
    LANGUAGE plpgsql
    AS $$

DECLARE
 toi integer;
 i integer;
 filled_count integer;

begin
	EXECUTE 'SELECT max(identifiers) FROM ontology.topographic_object_type_manifestations' INTO i;
	RETURN QUERY SELECT * FROM ontology.topographic_object_type_manifestations;
	-- GET DIAGNOSTICS i = ROW_COUNT;
	FOR toi in
	 SELECT DISTINCT(N.topographic_object_identifiers) FROM ontology.topographic_object_type_manifestations N ORDER BY N.topographic_object_identifiers
	LOOP
	 RETURN QUERY SELECT d.identifiers,d.topographic_object_identifiers,d.starts_at,d.ends_at,d.type_identifiers,d.historical_source_identifiers
	 FROM (
      SELECT	(i + (row_number() over ())::integer) AS identifiers,
				t.topographic_object_identifiers,
				t.ends_at AS starts_at,
				LEAD(t.starts_at) OVER (partition by t.topographic_object_identifiers = toi ORDER BY t.starts_at) AS ends_at,
				t.type_identifiers,
				NULL::integer AS historical_source_identifiers,
				LEAD(t.starts_at) OVER (partition by t.topographic_object_identifiers = toi ORDER BY t.starts_at) - t.ends_at AS diff
	  FROM ontology.topographic_object_type_manifestations t
	  WHERE t.topographic_object_identifiers = toi ORDER BY t.starts_at) d
	 WHERE d.diff > 0;
	GET DIAGNOSTICS filled_count = ROW_COUNT;
	-- raise notice 'i=%',filled_count;
	i := i + filled_count;
	END LOOP;
	RETURN;
END
$$;
 M   DROP FUNCTION ontology.topographic_object_type_manifestations_filled_func();
       ontology          postgres    false    4    207            �            1259    37968 	   functions    TABLE     w   CREATE TABLE ontology.functions (
    identifiers integer NOT NULL,
    iris text NOT NULL,
    names text NOT NULL
);
    DROP TABLE ontology.functions;
       ontology         heap    postgres    false    4            �           0    0    TABLE functions    COMMENT     i   COMMENT ON TABLE ontology.functions IS 'The contents of this table will be imported from the ontology.';
          ontology          postgres    false    208            �           0    0    COLUMN functions.iris    COMMENT     �   COMMENT ON COLUMN ontology.functions.iris IS 'This is to store internationalized resource identifiers - see: https://tools.ietf.org/html/rfc3987.';
          ontology          postgres    false    208            �            1259    37974    gt_pk_metadata    TABLE     �  CREATE TABLE ontology.gt_pk_metadata (
    table_schema character varying(32) NOT NULL,
    table_name character varying(32) NOT NULL,
    pk_column character varying(32) NOT NULL,
    pk_column_idx integer,
    pk_policy character varying(32),
    pk_sequence character varying(64),
    CONSTRAINT gt_pk_metadata_pk_policy_check CHECK (((pk_policy)::text = ANY (ARRAY[('sequence'::character varying)::text, ('assigned'::character varying)::text, ('autogenerated'::character varying)::text])))
);
 $   DROP TABLE ontology.gt_pk_metadata;
       ontology         heap    postgres    false    4            �            1259    37978    historical_evidences    TABLE     �   CREATE TABLE ontology.historical_evidences (
    identifiers integer NOT NULL,
    pages_from text,
    pages_to text,
    publication_identifiers text NOT NULL
);
 *   DROP TABLE ontology.historical_evidences;
       ontology         heap    postgres    false    4            �            1259    37984    location_datasets    TABLE     g   CREATE TABLE ontology.location_datasets (
    identifiers integer NOT NULL,
    names text NOT NULL
);
 '   DROP TABLE ontology.location_datasets;
       ontology         heap    postgres    false    4            �           0    0    TABLE location_datasets    COMMENT     w   COMMENT ON TABLE ontology.location_datasets IS 'This table is to register all sources for geographic reference data.';
          ontology          postgres    false    211            �            1259    37990    location_link_types    TABLE     �   CREATE TABLE ontology.location_link_types (
    identifiers integer NOT NULL,
    names text NOT NULL,
    postgis_functions text
);
 )   DROP TABLE ontology.location_link_types;
       ontology         heap    postgres    false    4            �            1259    37996    name_link_types    TABLE     e   CREATE TABLE ontology.name_link_types (
    identifiers integer NOT NULL,
    names text NOT NULL
);
 %   DROP TABLE ontology.name_link_types;
       ontology         heap    postgres    false    4            �            1259    38002 #   overlapping_function_manifestations    VIEW     �   CREATE VIEW ontology.overlapping_function_manifestations AS
 SELECT topographic_object_function_manifestations.topographic_object_identifiers
   FROM ontology.topographic_object_function_manifestations;
 8   DROP VIEW ontology.overlapping_function_manifestations;
       ontology          postgres    false    204    4            �            1259    38006    publication_sources    TABLE     s   CREATE TABLE ontology.publication_sources (
    identifiers text NOT NULL,
    bibliographic_data text NOT NULL
);
 )   DROP TABLE ontology.publication_sources;
       ontology         heap    postgres    false    4            �            1259    38012 1   topographic_object_function_manifestations_filled    MATERIALIZED VIEW     9  CREATE MATERIALIZED VIEW ontology.topographic_object_function_manifestations_filled AS
 SELECT topographic_object_function_manifestations_filled_func.identifiers,
    topographic_object_function_manifestations_filled_func.topographic_object_identifiers,
    topographic_object_function_manifestations_filled_func.starts_at,
    topographic_object_function_manifestations_filled_func.ends_at,
    topographic_object_function_manifestations_filled_func.function_identifiers,
    topographic_object_function_manifestations_filled_func.historical_source_identifiers
   FROM ontology.topographic_object_function_manifestations_filled_func() topographic_object_function_manifestations_filled_func(identifiers, topographic_object_identifiers, starts_at, ends_at, function_identifiers, historical_source_identifiers)
  WITH NO DATA;
 S   DROP MATERIALIZED VIEW ontology.topographic_object_function_manifestations_filled;
       ontology         heap    postgres    false    259    4            �            1259    38016 1   topographic_object_location_manifestations_filled    MATERIALIZED VIEW     �  CREATE MATERIALIZED VIEW ontology.topographic_object_location_manifestations_filled AS
 SELECT topographic_object_location_manifestations_filled_func.identifiers,
    topographic_object_location_manifestations_filled_func.topographic_object_identifiers,
    topographic_object_location_manifestations_filled_func.starts_at,
    topographic_object_location_manifestations_filled_func.ends_at,
    topographic_object_location_manifestations_filled_func.location_identifiers,
    topographic_object_location_manifestations_filled_func.historical_source_identifiers,
    topographic_object_location_manifestations_filled_func.location_link_type_identifiers
   FROM ontology.topographic_object_location_manifestations_filled_func() topographic_object_location_manifestations_filled_func(identifiers, topographic_object_identifiers, starts_at, ends_at, location_identifiers, historical_source_identifiers, location_link_type_identifiers)
  WITH NO DATA;
 S   DROP MATERIALIZED VIEW ontology.topographic_object_location_manifestations_filled;
       ontology         heap    postgres    false    260    4            �            1259    38020 3   topographic_object_mereological_link_manifestations    TABLE       CREATE TABLE ontology.topographic_object_mereological_link_manifestations (
    identifiers integer NOT NULL,
    starts_at date,
    ends_at date,
    whole_identifiers integer NOT NULL,
    part_identifiers integer NOT NULL,
    historical_evidence_identifiers integer NOT NULL
);
 I   DROP TABLE ontology.topographic_object_mereological_link_manifestations;
       ontology         heap    postgres    false    4            �            1259    38023 -   topographic_object_name_manifestations_filled    MATERIALIZED VIEW     f  CREATE MATERIALIZED VIEW ontology.topographic_object_name_manifestations_filled AS
 SELECT topographic_object_name_manifestations_filled_func.identifiers,
    topographic_object_name_manifestations_filled_func.topographic_object_identifiers,
    topographic_object_name_manifestations_filled_func.starts_at,
    topographic_object_name_manifestations_filled_func.ends_at,
    topographic_object_name_manifestations_filled_func.names,
    topographic_object_name_manifestations_filled_func.historical_source_identifiers,
    topographic_object_name_manifestations_filled_func.name_link_type_identifiers
   FROM ontology.topographic_object_name_manifestations_filled_func() topographic_object_name_manifestations_filled_func(identifiers, topographic_object_identifiers, starts_at, ends_at, names, historical_source_identifiers, name_link_type_identifiers)
  WITH NO DATA;
 O   DROP MATERIALIZED VIEW ontology.topographic_object_name_manifestations_filled;
       ontology         heap    postgres    false    261    4            �            1259    38030    topographic_object_provenances    TABLE     �   CREATE TABLE ontology.topographic_object_provenances (
    identifiers integer NOT NULL,
    ancestor_identifiers integer NOT NULL,
    predecessor_identifiers integer NOT NULL,
    historical_evidence_identifiers integer NOT NULL
);
 4   DROP TABLE ontology.topographic_object_provenances;
       ontology         heap    postgres    false    4            �            1259    38033 -   topographic_object_type_manifestations_filled    MATERIALIZED VIEW       CREATE MATERIALIZED VIEW ontology.topographic_object_type_manifestations_filled AS
 SELECT topographic_object_type_manifestations_filled_func.identifiers,
    topographic_object_type_manifestations_filled_func.topographic_object_identifiers,
    topographic_object_type_manifestations_filled_func.starts_at,
    topographic_object_type_manifestations_filled_func.ends_at,
    topographic_object_type_manifestations_filled_func.type_identifiers,
    topographic_object_type_manifestations_filled_func.historical_source_identifiers
   FROM ontology.topographic_object_type_manifestations_filled_func() topographic_object_type_manifestations_filled_func(identifiers, topographic_object_identifiers, starts_at, ends_at, type_identifiers, historical_source_identifiers)
  WITH NO DATA;
 O   DROP MATERIALIZED VIEW ontology.topographic_object_type_manifestations_filled;
       ontology         heap    postgres    false    262    4            �            1259    38037    topographic_objects    TABLE     h   CREATE TABLE ontology.topographic_objects (
    identifiers integer NOT NULL,
    default_names text
);
 )   DROP TABLE ontology.topographic_objects;
       ontology         heap    postgres    false    4            �            1259    38043    topographic_types    TABLE        CREATE TABLE ontology.topographic_types (
    identifiers integer NOT NULL,
    iris text NOT NULL,
    names text NOT NULL
);
 '   DROP TABLE ontology.topographic_types;
       ontology         heap    postgres    false    4            �           0    0    TABLE topographic_types    COMMENT     q   COMMENT ON TABLE ontology.topographic_types IS 'The contents of this table will be imported from the ontology.';
          ontology          postgres    false    223            �           0    0    COLUMN topographic_types.iris    COMMENT     �   COMMENT ON COLUMN ontology.topographic_types.iris IS 'This is to store internationalized resource identifiers - see: https://tools.ietf.org/html/rfc3987.';
          ontology          postgres    false    223            �            1259    38049    date_mappings    TABLE     u   CREATE TABLE ontology_sources.date_mappings (
    imprecise_date text NOT NULL,
    precise_date integer NOT NULL
);
 +   DROP TABLE ontology_sources.date_mappings;
       ontology_sources         heap    postgres    false    7            �           0    0    TABLE date_mappings    COMMENT     w   COMMENT ON TABLE ontology_sources.date_mappings IS 'This table is to store mappings from precise to imprecise dates.';
          ontology_sources          postgres    false    224            �            1259    38055 	   functions    TABLE     |   CREATE TABLE ontology_sources.functions (
    identifier integer NOT NULL,
    iri text NOT NULL,
    name text NOT NULL
);
 '   DROP TABLE ontology_sources.functions;
       ontology_sources         heap    postgres    false    7            �            1259    38061    historical_evidences    TABLE     �   CREATE TABLE ontology_sources.historical_evidences (
    identifier integer NOT NULL,
    page_from text,
    page_to text,
    publication_identifier text NOT NULL
);
 2   DROP TABLE ontology_sources.historical_evidences;
       ontology_sources         heap    postgres    false    7            �            1259    38067    location_datasets    TABLE     j   CREATE TABLE ontology_sources.location_datasets (
    name text NOT NULL,
    identifier text NOT NULL
);
 /   DROP TABLE ontology_sources.location_datasets;
       ontology_sources         heap    postgres    false    7            �            1259    38073 !   location_datasets_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.location_datasets_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 B   DROP SEQUENCE ontology_sources.location_datasets_identifiers_seq;
       ontology_sources          postgres    false    7    227            �           0    0 !   location_datasets_identifiers_seq    SEQUENCE OWNED BY     z   ALTER SEQUENCE ontology_sources.location_datasets_identifiers_seq OWNED BY ontology_sources.location_datasets.identifier;
          ontology_sources          postgres    false    228            �            1259    38075    location_link_types    TABLE     i   CREATE TABLE ontology_sources.location_link_types (
    name text NOT NULL,
    postgis_function text
);
 1   DROP TABLE ontology_sources.location_link_types;
       ontology_sources         heap    postgres    false    7            �           0    0    TABLE location_link_types    COMMENT     �   COMMENT ON TABLE ontology_sources.location_link_types IS 'This table is to store link type data for locations, e.g., such links as ''close to'', ''away from'', etc.';
          ontology_sources          postgres    false    229            �            1259    38081    locations_raw    TABLE     �   CREATE TABLE ontology_sources.locations_raw (
    identifier integer NOT NULL,
    the_geom text NOT NULL,
    name text,
    location_dataset_identifer text
);
 +   DROP TABLE ontology_sources.locations_raw;
       ontology_sources         heap    postgres    false    7            �            1259    38087    name_link_types    TABLE     J   CREATE TABLE ontology_sources.name_link_types (
    name text NOT NULL
);
 -   DROP TABLE ontology_sources.name_link_types;
       ontology_sources         heap    postgres    false    7            �           0    0    TABLE name_link_types    COMMENT     �   COMMENT ON TABLE ontology_sources.name_link_types IS 'This table is to store link type data for names, e.g., such links as ''is primary name of'', ''is a secondary name of'', ''is a common name of'', etc.';
          ontology_sources          postgres    false    231            �            1259    38093    publication_sources    TABLE     {   CREATE TABLE ontology_sources.publication_sources (
    identifier text NOT NULL,
    bibliographic_datum text NOT NULL
);
 1   DROP TABLE ontology_sources.publication_sources;
       ontology_sources         heap    postgres    false    7            �            1259    38099 *   topographic_object_function_manifestations    TABLE       CREATE TABLE ontology_sources.topographic_object_function_manifestations (
    topographic_object_identifier integer NOT NULL,
    start_at text,
    end_at text,
    function text NOT NULL,
    identifier integer NOT NULL,
    historical_evidence integer NOT NULL
);
 H   DROP TABLE ontology_sources.topographic_object_function_manifestations;
       ontology_sources         heap    postgres    false    7            �            1259    38105 ?   topographic_object_function_manifestation_sourc_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_function_manifestation_sourc_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 `   DROP SEQUENCE ontology_sources.topographic_object_function_manifestation_sourc_identifiers_seq;
       ontology_sources          postgres    false    7    233            �           0    0 ?   topographic_object_function_manifestation_sourc_identifiers_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE ontology_sources.topographic_object_function_manifestation_sourc_identifiers_seq OWNED BY ontology_sources.topographic_object_function_manifestations.identifier;
          ontology_sources          postgres    false    234            �            1259    38107 *   topographic_object_location_manifestations    TABLE     7  CREATE TABLE ontology_sources.topographic_object_location_manifestations (
    topographic_object_identifier integer NOT NULL,
    start_at text,
    end_at text,
    location_link_type text,
    identifier integer NOT NULL,
    location_identifier integer NOT NULL,
    historical_evidence integer NOT NULL
);
 H   DROP TABLE ontology_sources.topographic_object_location_manifestations;
       ontology_sources         heap    postgres    false    7            �            1259    38113 ?   topographic_object_location_manifestation_sourc_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_location_manifestation_sourc_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 `   DROP SEQUENCE ontology_sources.topographic_object_location_manifestation_sourc_identifiers_seq;
       ontology_sources          postgres    false    235    7            �           0    0 ?   topographic_object_location_manifestation_sourc_identifiers_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE ontology_sources.topographic_object_location_manifestation_sourc_identifiers_seq OWNED BY ontology_sources.topographic_object_location_manifestations.identifier;
          ontology_sources          postgres    false    236            �            1259    38115 3   topographic_object_mereological_link_manifestations    TABLE       CREATE TABLE ontology_sources.topographic_object_mereological_link_manifestations (
    start_at text,
    end_at text,
    whole_identifier integer NOT NULL,
    part_identifier integer NOT NULL,
    identifier integer NOT NULL,
    historical_evidence integer NOT NULL
);
 Q   DROP TABLE ontology_sources.topographic_object_mereological_link_manifestations;
       ontology_sources         heap    postgres    false    7            �            1259    38118 ?   topographic_object_mereological_link_manifestat_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_mereological_link_manifestat_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 `   DROP SEQUENCE ontology_sources.topographic_object_mereological_link_manifestat_identifiers_seq;
       ontology_sources          postgres    false    237    7            �           0    0 ?   topographic_object_mereological_link_manifestat_identifiers_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE ontology_sources.topographic_object_mereological_link_manifestat_identifiers_seq OWNED BY ontology_sources.topographic_object_mereological_link_manifestations.identifier;
          ontology_sources          postgres    false    238            �            1259    38120 &   topographic_object_name_manifestations    TABLE     &  CREATE TABLE ontology_sources.topographic_object_name_manifestations (
    topographic_object_identifier integer NOT NULL,
    start_at text,
    end_at text,
    name text NOT NULL,
    name_link_type text NOT NULL,
    identifier integer NOT NULL,
    historical_evidence integer NOT NULL
);
 D   DROP TABLE ontology_sources.topographic_object_name_manifestations;
       ontology_sources         heap    postgres    false    7            �            1259    38126 =   topographic_object_name_manifestation_sources_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_name_manifestation_sources_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ^   DROP SEQUENCE ontology_sources.topographic_object_name_manifestation_sources_identifiers_seq;
       ontology_sources          postgres    false    239    7            �           0    0 =   topographic_object_name_manifestation_sources_identifiers_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE ontology_sources.topographic_object_name_manifestation_sources_identifiers_seq OWNED BY ontology_sources.topographic_object_name_manifestations.identifier;
          ontology_sources          postgres    false    240            �            1259    44612    topographic_object_provenances    TABLE     �   CREATE TABLE ontology_sources.topographic_object_provenances (
    ancestor_identifier integer NOT NULL,
    predecessor_identifier integer NOT NULL,
    historical_evidence integer NOT NULL
);
 <   DROP TABLE ontology_sources.topographic_object_provenances;
       ontology_sources         heap    postgres    false    7            �            1259    38133 &   topographic_object_type_manifestations    TABLE       CREATE TABLE ontology_sources.topographic_object_type_manifestations (
    topographic_object_identifier integer NOT NULL,
    start_at text,
    end_at text,
    type text NOT NULL,
    identifier integer NOT NULL,
    historical_evidence integer NOT NULL
);
 D   DROP TABLE ontology_sources.topographic_object_type_manifestations;
       ontology_sources         heap    postgres    false    7            �            1259    38139 =   topographic_object_type_manifestation_sources_identifiers_seq    SEQUENCE     �   CREATE SEQUENCE ontology_sources.topographic_object_type_manifestation_sources_identifiers_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ^   DROP SEQUENCE ontology_sources.topographic_object_type_manifestation_sources_identifiers_seq;
       ontology_sources          postgres    false    241    7            �           0    0 =   topographic_object_type_manifestation_sources_identifiers_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE ontology_sources.topographic_object_type_manifestation_sources_identifiers_seq OWNED BY ontology_sources.topographic_object_type_manifestations.identifier;
          ontology_sources          postgres    false    242            �            1259    38141    topographic_objects    TABLE     n   CREATE TABLE ontology_sources.topographic_objects (
    identifier integer NOT NULL,
    default_name text
);
 1   DROP TABLE ontology_sources.topographic_objects;
       ontology_sources         heap    postgres    false    7            �           0    0 '   COLUMN topographic_objects.default_name    COMMENT     �   COMMENT ON COLUMN ontology_sources.topographic_objects.default_name IS 'This attribute stores any name for a topographic object in order to help a human to add manifestation-level data.';
          ontology_sources          postgres    false    243            �            1259    38147    topographic_types    TABLE     �   CREATE TABLE ontology_sources.topographic_types (
    identifier integer NOT NULL,
    iri text NOT NULL,
    name text NOT NULL
);
 /   DROP TABLE ontology_sources.topographic_types;
       ontology_sources         heap    postgres    false    7            @           2604    38153 5   topographic_object_function_manifestations identifier    DEFAULT     �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations ALTER COLUMN identifier SET DEFAULT nextval('ontology_sources.topographic_object_function_manifestation_sourc_identifiers_seq'::regclass);
 n   ALTER TABLE ontology_sources.topographic_object_function_manifestations ALTER COLUMN identifier DROP DEFAULT;
       ontology_sources          postgres    false    234    233            B           2604    38154 5   topographic_object_location_manifestations identifier    DEFAULT     �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations ALTER COLUMN identifier SET DEFAULT nextval('ontology_sources.topographic_object_location_manifestation_sourc_identifiers_seq'::regclass);
 n   ALTER TABLE ontology_sources.topographic_object_location_manifestations ALTER COLUMN identifier DROP DEFAULT;
       ontology_sources          postgres    false    236    235            D           2604    38155 >   topographic_object_mereological_link_manifestations identifier    DEFAULT     �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations ALTER COLUMN identifier SET DEFAULT nextval('ontology_sources.topographic_object_mereological_link_manifestat_identifiers_seq'::regclass);
 w   ALTER TABLE ontology_sources.topographic_object_mereological_link_manifestations ALTER COLUMN identifier DROP DEFAULT;
       ontology_sources          postgres    false    238    237            F           2604    38156 1   topographic_object_name_manifestations identifier    DEFAULT     �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations ALTER COLUMN identifier SET DEFAULT nextval('ontology_sources.topographic_object_name_manifestation_sources_identifiers_seq'::regclass);
 j   ALTER TABLE ontology_sources.topographic_object_name_manifestations ALTER COLUMN identifier DROP DEFAULT;
       ontology_sources          postgres    false    240    239            H           2604    38158 1   topographic_object_type_manifestations identifier    DEFAULT     �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations ALTER COLUMN identifier SET DEFAULT nextval('ontology_sources.topographic_object_type_manifestation_sources_identifiers_seq'::regclass);
 j   ALTER TABLE ontology_sources.topographic_object_type_manifestations ALTER COLUMN identifier DROP DEFAULT;
       ontology_sources          postgres    false    242    241            `          0    37968 	   functions 
   TABLE DATA           ?   COPY ontology.functions (identifiers, iris, names) FROM stdin;
    ontology          postgres    false    208   ��      a          0    37974    gt_pk_metadata 
   TABLE DATA           v   COPY ontology.gt_pk_metadata (table_schema, table_name, pk_column, pk_column_idx, pk_policy, pk_sequence) FROM stdin;
    ontology          postgres    false    209   �      b          0    37978    historical_evidences 
   TABLE DATA           l   COPY ontology.historical_evidences (identifiers, pages_from, pages_to, publication_identifiers) FROM stdin;
    ontology          postgres    false    210   �      c          0    37984    location_datasets 
   TABLE DATA           A   COPY ontology.location_datasets (identifiers, names) FROM stdin;
    ontology          postgres    false    211   �      d          0    37990    location_link_types 
   TABLE DATA           V   COPY ontology.location_link_types (identifiers, names, postgis_functions) FROM stdin;
    ontology          postgres    false    212   j�      e          0    37996    name_link_types 
   TABLE DATA           ?   COPY ontology.name_link_types (identifiers, names) FROM stdin;
    ontology          postgres    false    213   z�      f          0    38006    publication_sources 
   TABLE DATA           P   COPY ontology.publication_sources (identifiers, bibliographic_data) FROM stdin;
    ontology          postgres    false    215   ��      \          0    37948 *   topographic_object_function_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_function_manifestations (identifiers, topographic_object_identifiers, starts_at, ends_at, function_identifiers, historical_evidence_identifiers) FROM stdin;
    ontology          postgres    false    204   ��      ]          0    37952 *   topographic_object_location_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_location_manifestations (identifiers, topographic_object_identifiers, starts_at, ends_at, location_identifiers, historical_evidence_identifiers, location_link_type_identifiers) FROM stdin;
    ontology          postgres    false    205   ��      i          0    38020 3   topographic_object_mereological_link_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_mereological_link_manifestations (identifiers, starts_at, ends_at, whole_identifiers, part_identifiers, historical_evidence_identifiers) FROM stdin;
    ontology          postgres    false    218   Ƽ      ^          0    37956 &   topographic_object_name_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_name_manifestations (identifiers, topographic_object_identifiers, starts_at, ends_at, names, historical_evidence_identifiers, name_link_type_identifiers) FROM stdin;
    ontology          postgres    false    206   ֽ      k          0    38030    topographic_object_provenances 
   TABLE DATA           �   COPY ontology.topographic_object_provenances (identifiers, ancestor_identifiers, predecessor_identifiers, historical_evidence_identifiers) FROM stdin;
    ontology          postgres    false    220   �      _          0    37964 &   topographic_object_type_manifestations 
   TABLE DATA           �   COPY ontology.topographic_object_type_manifestations (identifiers, topographic_object_identifiers, starts_at, ends_at, type_identifiers, historical_evidence_identifiers) FROM stdin;
    ontology          postgres    false    207   �      m          0    38037    topographic_objects 
   TABLE DATA           K   COPY ontology.topographic_objects (identifiers, default_names) FROM stdin;
    ontology          postgres    false    222   ��      n          0    38043    topographic_types 
   TABLE DATA           G   COPY ontology.topographic_types (identifiers, iris, names) FROM stdin;
    ontology          postgres    false    223   B�      o          0    38049    date_mappings 
   TABLE DATA           O   COPY ontology_sources.date_mappings (imprecise_date, precise_date) FROM stdin;
    ontology_sources          postgres    false    224   �      p          0    38055 	   functions 
   TABLE DATA           D   COPY ontology_sources.functions (identifier, iri, name) FROM stdin;
    ontology_sources          postgres    false    225   �      q          0    38061    historical_evidences 
   TABLE DATA           p   COPY ontology_sources.historical_evidences (identifier, page_from, page_to, publication_identifier) FROM stdin;
    ontology_sources          postgres    false    226   x      r          0    38067    location_datasets 
   TABLE DATA           G   COPY ontology_sources.location_datasets (name, identifier) FROM stdin;
    ontology_sources          postgres    false    227   h      t          0    38075    location_link_types 
   TABLE DATA           O   COPY ontology_sources.location_link_types (name, postgis_function) FROM stdin;
    ontology_sources          postgres    false    229   �      u          0    38081    locations_raw 
   TABLE DATA           i   COPY ontology_sources.locations_raw (identifier, the_geom, name, location_dataset_identifer) FROM stdin;
    ontology_sources          postgres    false    230   �      v          0    38087    name_link_types 
   TABLE DATA           9   COPY ontology_sources.name_link_types (name) FROM stdin;
    ontology_sources          postgres    false    231   �,      w          0    38093    publication_sources 
   TABLE DATA           X   COPY ontology_sources.publication_sources (identifier, bibliographic_datum) FROM stdin;
    ontology_sources          postgres    false    232   �,      x          0    38099 *   topographic_object_function_manifestations 
   TABLE DATA           �   COPY ontology_sources.topographic_object_function_manifestations (topographic_object_identifier, start_at, end_at, function, identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    233   �8      z          0    38107 *   topographic_object_location_manifestations 
   TABLE DATA           �   COPY ontology_sources.topographic_object_location_manifestations (topographic_object_identifier, start_at, end_at, location_link_type, identifier, location_identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    235   �;      |          0    38115 3   topographic_object_mereological_link_manifestations 
   TABLE DATA           �   COPY ontology_sources.topographic_object_mereological_link_manifestations (start_at, end_at, whole_identifier, part_identifier, identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    237   �D      ~          0    38120 &   topographic_object_name_manifestations 
   TABLE DATA           �   COPY ontology_sources.topographic_object_name_manifestations (topographic_object_identifier, start_at, end_at, name, name_link_type, identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    239   �E      �          0    44612    topographic_object_provenances 
   TABLE DATA           �   COPY ontology_sources.topographic_object_provenances (ancestor_identifier, predecessor_identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    245   HV      �          0    38133 &   topographic_object_type_manifestations 
   TABLE DATA           �   COPY ontology_sources.topographic_object_type_manifestations (topographic_object_identifier, start_at, end_at, type, identifier, historical_evidence) FROM stdin;
    ontology_sources          postgres    false    241    W      �          0    38141    topographic_objects 
   TABLE DATA           Q   COPY ontology_sources.topographic_objects (identifier, default_name) FROM stdin;
    ontology_sources          postgres    false    243   =W      �          0    38147    topographic_types 
   TABLE DATA           L   COPY ontology_sources.topographic_types (identifier, iri, name) FROM stdin;
    ontology_sources          postgres    false    244   �a      �           0    0 !   location_datasets_identifiers_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('ontology_sources.location_datasets_identifiers_seq', 1, false);
          ontology_sources          postgres    false    228            �           0    0 ?   topographic_object_function_manifestation_sourc_identifiers_seq    SEQUENCE SET     z   SELECT pg_catalog.setval('ontology_sources.topographic_object_function_manifestation_sourc_identifiers_seq', 1031, true);
          ontology_sources          postgres    false    234            �           0    0 ?   topographic_object_location_manifestation_sourc_identifiers_seq    SEQUENCE SET     z   SELECT pg_catalog.setval('ontology_sources.topographic_object_location_manifestation_sourc_identifiers_seq', 4272, true);
          ontology_sources          postgres    false    236            �           0    0 ?   topographic_object_mereological_link_manifestat_identifiers_seq    SEQUENCE SET     y   SELECT pg_catalog.setval('ontology_sources.topographic_object_mereological_link_manifestat_identifiers_seq', 312, true);
          ontology_sources          postgres    false    238            �           0    0 =   topographic_object_name_manifestation_sources_identifiers_seq    SEQUENCE SET     x   SELECT pg_catalog.setval('ontology_sources.topographic_object_name_manifestation_sources_identifiers_seq', 2969, true);
          ontology_sources          postgres    false    240            �           0    0 =   topographic_object_type_manifestation_sources_identifiers_seq    SEQUENCE SET     w   SELECT pg_catalog.setval('ontology_sources.topographic_object_type_manifestation_sources_identifiers_seq', 569, true);
          ontology_sources          postgres    false    242            [           2606    38160    functions Functions_IRIs_key 
   CONSTRAINT     [   ALTER TABLE ONLY ontology.functions
    ADD CONSTRAINT "Functions_IRIs_key" UNIQUE (iris);
 J   ALTER TABLE ONLY ontology.functions DROP CONSTRAINT "Functions_IRIs_key";
       ontology            postgres    false    208            ]           2606    38162    functions Functions_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY ontology.functions
    ADD CONSTRAINT "Functions_pkey" PRIMARY KEY (identifiers);
 F   ALTER TABLE ONLY ontology.functions DROP CONSTRAINT "Functions_pkey";
       ontology            postgres    false    208            }           2606    38164 &   topographic_types TopgraphicTypes_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY ontology.topographic_types
    ADD CONSTRAINT "TopgraphicTypes_pkey" PRIMARY KEY (identifiers);
 T   ALTER TABLE ONLY ontology.topographic_types DROP CONSTRAINT "TopgraphicTypes_pkey";
       ontology            postgres    false    223            K           2606    38166 W   topographic_object_function_manifestations TopographicObjectFunctionManifestations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations
    ADD CONSTRAINT "TopographicObjectFunctionManifestations_pkey" PRIMARY KEY (identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations DROP CONSTRAINT "TopographicObjectFunctionManifestations_pkey";
       ontology            postgres    false    204            O           2606    38168 J   topographic_object_location_manifestations TopographicObjectLocations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations
    ADD CONSTRAINT "TopographicObjectLocations_pkey" PRIMARY KEY (identifiers);
 x   ALTER TABLE ONLY ontology.topographic_object_location_manifestations DROP CONSTRAINT "TopographicObjectLocations_pkey";
       ontology            postgres    false    205            u           2606    38170 h   topographic_object_mereological_link_manifestations TopographicObjectMereologicalLinkManifestations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT "TopographicObjectMereologicalLinkManifestations_pkey" PRIMARY KEY (identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT "TopographicObjectMereologicalLinkManifestations_pkey";
       ontology            postgres    false    218            S           2606    38172 O   topographic_object_name_manifestations TopographicObjectNameManifestations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations
    ADD CONSTRAINT "TopographicObjectNameManifestations_pkey" PRIMARY KEY (identifiers);
 }   ALTER TABLE ONLY ontology.topographic_object_name_manifestations DROP CONSTRAINT "TopographicObjectNameManifestations_pkey";
       ontology            postgres    false    206            W           2606    38174 O   topographic_object_type_manifestations TopographicObjectTypeManifestations_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations
    ADD CONSTRAINT "TopographicObjectTypeManifestations_pkey" PRIMARY KEY (identifiers);
 }   ALTER TABLE ONLY ontology.topographic_object_type_manifestations DROP CONSTRAINT "TopographicObjectTypeManifestations_pkey";
       ontology            postgres    false    207            {           2606    38176 +   topographic_objects TopographicObjects_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY ontology.topographic_objects
    ADD CONSTRAINT "TopographicObjects_pkey" PRIMARY KEY (identifiers);
 Y   ALTER TABLE ONLY ontology.topographic_objects DROP CONSTRAINT "TopographicObjects_pkey";
       ontology            postgres    false    222                       2606    38178 +   topographic_types TopographicTypes_IRIs_key 
   CONSTRAINT     j   ALTER TABLE ONLY ontology.topographic_types
    ADD CONSTRAINT "TopographicTypes_IRIs_key" UNIQUE (iris);
 Y   ALTER TABLE ONLY ontology.topographic_types DROP CONSTRAINT "TopographicTypes_IRIs_key";
       ontology            postgres    false    223            _           2606    38180    functions functions_names_key 
   CONSTRAINT     [   ALTER TABLE ONLY ontology.functions
    ADD CONSTRAINT functions_names_key UNIQUE (names);
 I   ALTER TABLE ONLY ontology.functions DROP CONSTRAINT functions_names_key;
       ontology            postgres    false    208            a           2606    38182 C   gt_pk_metadata gt_pk_metadata_table_schema_table_name_pk_column_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.gt_pk_metadata
    ADD CONSTRAINT gt_pk_metadata_table_schema_table_name_pk_column_key UNIQUE (table_schema, table_name, pk_column);
 o   ALTER TABLE ONLY ontology.gt_pk_metadata DROP CONSTRAINT gt_pk_metadata_table_schema_table_name_pk_column_key;
       ontology            postgres    false    209    209    209            c           2606    38184 .   historical_evidences historical_evidences_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY ontology.historical_evidences
    ADD CONSTRAINT historical_evidences_pkey PRIMARY KEY (identifiers);
 Z   ALTER TABLE ONLY ontology.historical_evidences DROP CONSTRAINT historical_evidences_pkey;
       ontology            postgres    false    210            e           2606    38186 ,   historical_evidences historical_evidences_un 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.historical_evidences
    ADD CONSTRAINT historical_evidences_un UNIQUE (pages_from, pages_to, publication_identifiers);
 X   ALTER TABLE ONLY ontology.historical_evidences DROP CONSTRAINT historical_evidences_un;
       ontology            postgres    false    210    210    210            g           2606    38188 2   location_datasets location_dataset_types_names_key 
   CONSTRAINT     p   ALTER TABLE ONLY ontology.location_datasets
    ADD CONSTRAINT location_dataset_types_names_key UNIQUE (names);
 ^   ALTER TABLE ONLY ontology.location_datasets DROP CONSTRAINT location_dataset_types_names_key;
       ontology            postgres    false    211            k           2606    38190 1   location_link_types location_link_types_names_key 
   CONSTRAINT     o   ALTER TABLE ONLY ontology.location_link_types
    ADD CONSTRAINT location_link_types_names_key UNIQUE (names);
 ]   ALTER TABLE ONLY ontology.location_link_types DROP CONSTRAINT location_link_types_names_key;
       ontology            postgres    false    212            m           2606    38192 ,   location_link_types location_link_types_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY ontology.location_link_types
    ADD CONSTRAINT location_link_types_pkey PRIMARY KEY (identifiers);
 X   ALTER TABLE ONLY ontology.location_link_types DROP CONSTRAINT location_link_types_pkey;
       ontology            postgres    false    212            i           2606    38194 %   location_datasets location_types_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY ontology.location_datasets
    ADD CONSTRAINT location_types_pkey PRIMARY KEY (identifiers);
 Q   ALTER TABLE ONLY ontology.location_datasets DROP CONSTRAINT location_types_pkey;
       ontology            postgres    false    211            o           2606    38196 )   name_link_types name_link_types_names_key 
   CONSTRAINT     g   ALTER TABLE ONLY ontology.name_link_types
    ADD CONSTRAINT name_link_types_names_key UNIQUE (names);
 U   ALTER TABLE ONLY ontology.name_link_types DROP CONSTRAINT name_link_types_names_key;
       ontology            postgres    false    213            q           2606    38198 $   name_link_types name_link_types_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY ontology.name_link_types
    ADD CONSTRAINT name_link_types_pkey PRIMARY KEY (identifiers);
 P   ALTER TABLE ONLY ontology.name_link_types DROP CONSTRAINT name_link_types_pkey;
       ontology            postgres    false    213            s           2606    38200 ,   publication_sources publication_sources_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY ontology.publication_sources
    ADD CONSTRAINT publication_sources_pkey PRIMARY KEY (identifiers);
 X   ALTER TABLE ONLY ontology.publication_sources DROP CONSTRAINT publication_sources_pkey;
       ontology            postgres    false    215            M           2606    38202 j   topographic_object_function_manifestations topographic_object_function_m_topographic_object_identifier_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_m_topographic_object_identifier_key UNIQUE (topographic_object_identifiers, function_identifiers, starts_at, ends_at);
 �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_m_topographic_object_identifier_key;
       ontology            postgres    false    204    204    204    204            5           2606    38203 [   topographic_object_function_manifestations topographic_object_function_manifestations_check    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestations_check CHECK ((NOT ((starts_at IS NULL) AND (ends_at IS NULL)))) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestations_check;
       ontology          postgres    false    204    204    204    204            6           2606    38204 \   topographic_object_function_manifestations topographic_object_function_manifestations_check1    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestations_check1 CHECK ((starts_at <= ends_at)) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestations_check1;
       ontology          postgres    false    204    204    204    204            Q           2606    38206 j   topographic_object_location_manifestations topographic_object_location_m_topographic_object_identifier_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_m_topographic_object_identifier_key UNIQUE (topographic_object_identifiers, location_identifiers, starts_at, ends_at);
 �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_m_topographic_object_identifier_key;
       ontology            postgres    false    205    205    205    205            7           2606    38207 [   topographic_object_location_manifestations topographic_object_location_manifestations_check    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestations_check CHECK ((NOT ((starts_at IS NULL) AND (ends_at IS NULL)))) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestations_check;
       ontology          postgres    false    205    205    205    205            8           2606    38208 \   topographic_object_location_manifestations topographic_object_location_manifestations_check1    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestations_check1 CHECK ((starts_at <= ends_at)) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestations_check1;
       ontology          postgres    false    205    205    205    205            w           2606    38210 s   topographic_object_mereological_link_manifestations topographic_object_mereologic_whole_identifiers_part_identi_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereologic_whole_identifiers_part_identi_key UNIQUE (whole_identifiers, part_identifiers, starts_at, ends_at);
 �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereologic_whole_identifiers_part_identi_key;
       ontology            postgres    false    218    218    218    218            >           2606    38211 m   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestations_check    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestations_check CHECK ((NOT ((starts_at IS NULL) AND (ends_at IS NULL)))) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestations_check;
       ontology          postgres    false    218    218    218    218            ?           2606    38212 n   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestations_check1    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestations_check1 CHECK ((starts_at <= ends_at)) NOT VALID;
 �   ALTER TABLE ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestations_check1;
       ontology          postgres    false    218    218    218    218            U           2606    38214 f   topographic_object_name_manifestations topographic_object_name_manif_topographic_object_identifier_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manif_topographic_object_identifier_key UNIQUE (topographic_object_identifiers, starts_at, ends_at, names);
 �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manif_topographic_object_identifier_key;
       ontology            postgres    false    206    206    206    206            :           2606    38215 T   topographic_object_name_manifestations topographic_object_name_manifestations_check1    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestations_check1 CHECK ((starts_at <= ends_at)) NOT VALID;
 {   ALTER TABLE ontology.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestations_check1;
       ontology          postgres    false    206    206    206    206            y           2606    38217 B   topographic_object_provenances topographic_object_provenances_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_pkey PRIMARY KEY (identifiers);
 n   ALTER TABLE ONLY ontology.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_pkey;
       ontology            postgres    false    220            Y           2606    38219 f   topographic_object_type_manifestations topographic_object_type_manif_topographic_object_identifier_key 
   CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manif_topographic_object_identifier_key UNIQUE (topographic_object_identifiers, starts_at, ends_at, type_identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manif_topographic_object_identifier_key;
       ontology            postgres    false    207    207    207    207            ;           2606    38220 S   topographic_object_type_manifestations topographic_object_type_manifestations_check    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestations_check CHECK ((NOT ((starts_at IS NULL) AND (ends_at IS NULL)))) NOT VALID;
 z   ALTER TABLE ontology.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestations_check;
       ontology          postgres    false    207    207    207    207            <           2606    38221 T   topographic_object_type_manifestations topographic_object_type_manifestations_check1    CHECK CONSTRAINT     �   ALTER TABLE ontology.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestations_check1 CHECK ((starts_at <= ends_at)) NOT VALID;
 {   ALTER TABLE ontology.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestations_check1;
       ontology          postgres    false    207    207    207    207            �           2606    38223 ,   date_mappings date_maps_historical_dates_key 
   CONSTRAINT     {   ALTER TABLE ONLY ontology_sources.date_mappings
    ADD CONSTRAINT date_maps_historical_dates_key UNIQUE (imprecise_date);
 `   ALTER TABLE ONLY ontology_sources.date_mappings DROP CONSTRAINT date_maps_historical_dates_key;
       ontology_sources            postgres    false    224            �           2606    38225    functions functions_iris_key 
   CONSTRAINT     `   ALTER TABLE ONLY ontology_sources.functions
    ADD CONSTRAINT functions_iris_key UNIQUE (iri);
 P   ALTER TABLE ONLY ontology_sources.functions DROP CONSTRAINT functions_iris_key;
       ontology_sources            postgres    false    225            �           2606    38227    functions functions_names_key 
   CONSTRAINT     b   ALTER TABLE ONLY ontology_sources.functions
    ADD CONSTRAINT functions_names_key UNIQUE (name);
 Q   ALTER TABLE ONLY ontology_sources.functions DROP CONSTRAINT functions_names_key;
       ontology_sources            postgres    false    225            �           2606    38229    functions functions_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY ontology_sources.functions
    ADD CONSTRAINT functions_pkey PRIMARY KEY (identifier);
 L   ALTER TABLE ONLY ontology_sources.functions DROP CONSTRAINT functions_pkey;
       ontology_sources            postgres    false    225            �           2606    38231 ,   historical_evidences historical_evidences_pk 
   CONSTRAINT     |   ALTER TABLE ONLY ontology_sources.historical_evidences
    ADD CONSTRAINT historical_evidences_pk PRIMARY KEY (identifier);
 `   ALTER TABLE ONLY ontology_sources.historical_evidences DROP CONSTRAINT historical_evidences_pk;
       ontology_sources            postgres    false    226            �           2606    38233 ,   historical_evidences historical_evidences_un 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.historical_evidences
    ADD CONSTRAINT historical_evidences_un UNIQUE (page_from, page_to, publication_identifier);
 `   ALTER TABLE ONLY ontology_sources.historical_evidences DROP CONSTRAINT historical_evidences_un;
       ontology_sources            postgres    false    226    226    226            �           2606    38235 1   publication_sources historical_sources_sources_pk 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.publication_sources
    ADD CONSTRAINT historical_sources_sources_pk PRIMARY KEY (identifier);
 e   ALTER TABLE ONLY ontology_sources.publication_sources DROP CONSTRAINT historical_sources_sources_pk;
       ontology_sources            postgres    false    232            �           2606    38237 1   publication_sources historical_sources_titles_key 
   CONSTRAINT     |   ALTER TABLE ONLY ontology_sources.publication_sources
    ADD CONSTRAINT historical_sources_titles_key UNIQUE (identifier);
 e   ALTER TABLE ONLY ontology_sources.publication_sources DROP CONSTRAINT historical_sources_titles_key;
       ontology_sources            postgres    false    232            �           2606    38239 -   location_datasets location_datasets_names_key 
   CONSTRAINT     r   ALTER TABLE ONLY ontology_sources.location_datasets
    ADD CONSTRAINT location_datasets_names_key UNIQUE (name);
 a   ALTER TABLE ONLY ontology_sources.location_datasets DROP CONSTRAINT location_datasets_names_key;
       ontology_sources            postgres    false    227            �           2606    38241 (   location_datasets location_datasets_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY ontology_sources.location_datasets
    ADD CONSTRAINT location_datasets_pkey PRIMARY KEY (identifier);
 \   ALTER TABLE ONLY ontology_sources.location_datasets DROP CONSTRAINT location_datasets_pkey;
       ontology_sources            postgres    false    227            �           2606    38243 3   location_link_types location_link_type_sources_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY ontology_sources.location_link_types
    ADD CONSTRAINT location_link_type_sources_pkey PRIMARY KEY (name);
 g   ALTER TABLE ONLY ontology_sources.location_link_types DROP CONSTRAINT location_link_type_sources_pkey;
       ontology_sources            postgres    false    229            �           2606    38245    locations_raw locations_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY ontology_sources.locations_raw
    ADD CONSTRAINT locations_pkey PRIMARY KEY (identifier);
 P   ALTER TABLE ONLY ontology_sources.locations_raw DROP CONSTRAINT locations_pkey;
       ontology_sources            postgres    false    230            �           2606    38247 +   name_link_types name_link_type_sources_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY ontology_sources.name_link_types
    ADD CONSTRAINT name_link_type_sources_pkey PRIMARY KEY (name);
 _   ALTER TABLE ONLY ontology_sources.name_link_types DROP CONSTRAINT name_link_type_sources_pkey;
       ontology_sources            postgres    false    231            A           2606    42460 b   topographic_object_function_manifestations topographic_object_function_manifestation_sources_check    CHECK CONSTRAINT     �   ALTER TABLE ontology_sources.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestation_sources_check CHECK (((start_at IS NOT NULL) OR (end_at IS NOT NULL))) NOT VALID;
 �   ALTER TABLE ontology_sources.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestation_sources_check;
       ontology_sources          postgres    false    233    233    233    233            �           2606    38250 a   topographic_object_function_manifestations topographic_object_function_manifestation_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestation_sources_pkey PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestation_sources_pkey;
       ontology_sources            postgres    false    233            C           2606    42303 b   topographic_object_location_manifestations topographic_object_location_manifestation_sources_check    CHECK CONSTRAINT     �   ALTER TABLE ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestation_sources_check CHECK (((start_at IS NOT NULL) OR (end_at IS NOT NULL))) NOT VALID;
 �   ALTER TABLE ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestation_sources_check;
       ontology_sources          postgres    false    235    235    235    235            �           2606    38253 a   topographic_object_location_manifestations topographic_object_location_manifestation_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestation_sources_pkey PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestation_sources_pkey;
       ontology_sources            postgres    false    235            E           2606    42517 s   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestation_source_check    CHECK CONSTRAINT     �   ALTER TABLE ontology_sources.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestation_source_check CHECK (((start_at IS NOT NULL) OR (end_at IS NOT NULL))) NOT VALID;
 �   ALTER TABLE ontology_sources.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestation_source_check;
       ontology_sources          postgres    false    237    237    237    237            �           2606    38256 s   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestation_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestation_sources_pkey PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestation_sources_pkey;
       ontology_sources            postgres    false    237            G           2606    42498 Z   topographic_object_name_manifestations topographic_object_name_manifestation_sources_check    CHECK CONSTRAINT     �   ALTER TABLE ontology_sources.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestation_sources_check CHECK (((start_at IS NOT NULL) OR (end_at IS NOT NULL))) NOT VALID;
 �   ALTER TABLE ontology_sources.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestation_sources_check;
       ontology_sources          postgres    false    239    239    239    239            �           2606    38259 Y   topographic_object_name_manifestations topographic_object_name_manifestation_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestation_sources_pkey PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestation_sources_pkey;
       ontology_sources            postgres    false    239            �           2606    38263 3   topographic_objects topographic_object_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_objects
    ADD CONSTRAINT topographic_object_sources_pkey PRIMARY KEY (identifier);
 g   ALTER TABLE ONLY ontology_sources.topographic_objects DROP CONSTRAINT topographic_object_sources_pkey;
       ontology_sources            postgres    false    243            I           2606    42482 Z   topographic_object_type_manifestations topographic_object_type_manifestation_sources_check    CHECK CONSTRAINT     �   ALTER TABLE ontology_sources.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestation_sources_check CHECK (((start_at IS NOT NULL) OR (end_at IS NOT NULL))) NOT VALID;
 �   ALTER TABLE ontology_sources.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestation_sources_check;
       ontology_sources          postgres    false    241    241    241    241            �           2606    38266 Y   topographic_object_type_manifestations topographic_object_type_manifestation_sources_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestation_sources_pkey PRIMARY KEY (identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestation_sources_pkey;
       ontology_sources            postgres    false    241            �           2606    38268 ,   topographic_types topographic_types_iris_key 
   CONSTRAINT     p   ALTER TABLE ONLY ontology_sources.topographic_types
    ADD CONSTRAINT topographic_types_iris_key UNIQUE (iri);
 `   ALTER TABLE ONLY ontology_sources.topographic_types DROP CONSTRAINT topographic_types_iris_key;
       ontology_sources            postgres    false    244            �           2606    38270 -   topographic_types topographic_types_names_key 
   CONSTRAINT     r   ALTER TABLE ONLY ontology_sources.topographic_types
    ADD CONSTRAINT topographic_types_names_key UNIQUE (name);
 a   ALTER TABLE ONLY ontology_sources.topographic_types DROP CONSTRAINT topographic_types_names_key;
       ontology_sources            postgres    false    244            �           2606    38272 (   topographic_types topographic_types_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY ontology_sources.topographic_types
    ADD CONSTRAINT topographic_types_pkey PRIMARY KEY (identifier);
 \   ALTER TABLE ONLY ontology_sources.topographic_types DROP CONSTRAINT topographic_types_pkey;
       ontology_sources            postgres    false    244            �           1259    44789 ?   topographic_object_function_manifestations_topographic_object_i    INDEX     �   CREATE UNIQUE INDEX topographic_object_function_manifestations_topographic_object_i ON ontology_sources.topographic_object_function_manifestations USING btree (topographic_object_identifier, start_at, end_at, function);
 ]   DROP INDEX ontology_sources.topographic_object_function_manifestations_topographic_object_i;
       ontology_sources            postgres    false    233    233    233    233            �           1259    44790 ?   topographic_object_location_manifestations_topographic_object_i    INDEX     �   CREATE UNIQUE INDEX topographic_object_location_manifestations_topographic_object_i ON ontology_sources.topographic_object_location_manifestations USING btree (topographic_object_identifier, start_at, end_at, location_link_type, location_identifier);
 ]   DROP INDEX ontology_sources.topographic_object_location_manifestations_topographic_object_i;
       ontology_sources            postgres    false    235    235    235    235    235            �           1259    44791 ?   topographic_object_mereological_link_manifestations_starts_at_i    INDEX     �   CREATE INDEX topographic_object_mereological_link_manifestations_starts_at_i ON ontology_sources.topographic_object_mereological_link_manifestations USING btree (start_at, end_at, whole_identifier, part_identifier);
 ]   DROP INDEX ontology_sources.topographic_object_mereological_link_manifestations_starts_at_i;
       ontology_sources            postgres    false    237    237    237    237            �           1259    44792 ?   topographic_object_name_manifestations_topographic_object_ident    INDEX     �   CREATE INDEX topographic_object_name_manifestations_topographic_object_ident ON ontology_sources.topographic_object_name_manifestations USING btree (topographic_object_identifier, start_at, end_at, name, name_link_type);
 ]   DROP INDEX ontology_sources.topographic_object_name_manifestations_topographic_object_ident;
       ontology_sources            postgres    false    239    239    239    239    239            �           1259    44794 7   topographic_object_provenances_ancestor_identifiers_idx    INDEX     �   CREATE UNIQUE INDEX topographic_object_provenances_ancestor_identifiers_idx ON ontology_sources.topographic_object_provenances USING btree (ancestor_identifier, predecessor_identifier);
 U   DROP INDEX ontology_sources.topographic_object_provenances_ancestor_identifiers_idx;
       ontology_sources            postgres    false    245    245            �           1259    44793 ?   topographic_object_type_manifestations_topographic_object_ident    INDEX     �   CREATE UNIQUE INDEX topographic_object_type_manifestations_topographic_object_ident ON ontology_sources.topographic_object_type_manifestations USING btree (topographic_object_identifier, start_at, end_at, type);
 ]   DROP INDEX ontology_sources.topographic_object_type_manifestations_topographic_object_ident;
       ontology_sources            postgres    false    241    241    241    241            �           2606    38273 j   topographic_object_function_manifestations TopographicObjectFunctionMani_TopographicObjectIdentifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations
    ADD CONSTRAINT "TopographicObjectFunctionMani_TopographicObjectIdentifiers_fkey" FOREIGN KEY (topographic_object_identifiers) REFERENCES ontology.topographic_objects(identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations DROP CONSTRAINT "TopographicObjectFunctionMani_TopographicObjectIdentifiers_fkey";
       ontology          postgres    false    204    2939    222            �           2606    38278 j   topographic_object_function_manifestations TopographicObjectFunctionManifestation_FunctionIdentifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations
    ADD CONSTRAINT "TopographicObjectFunctionManifestation_FunctionIdentifiers_fkey" FOREIGN KEY (function_identifiers) REFERENCES ontology.functions(identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations DROP CONSTRAINT "TopographicObjectFunctionManifestation_FunctionIdentifiers_fkey";
       ontology          postgres    false    2909    204    208            �           2606    38283 j   topographic_object_location_manifestations TopographicObjectLocationMani_TopographicObjectIdentifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology.topographic_object_location_manifestations
    ADD CONSTRAINT "TopographicObjectLocationMani_TopographicObjectIdentifiers_fkey" FOREIGN KEY (topographic_object_identifiers) REFERENCES ontology.topographic_objects(identifiers) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations DROP CONSTRAINT "TopographicObjectLocationMani_TopographicObjectIdentifiers_fkey";
       ontology          postgres    false    205    2939    222            �           2606    38288 s   topographic_object_mereological_link_manifestations TopographicObjectMereologicalLinkManifest_WholeIdentifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT "TopographicObjectMereologicalLinkManifest_WholeIdentifiers_fkey" FOREIGN KEY (whole_identifiers) REFERENCES ontology.topographic_objects(identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT "TopographicObjectMereologicalLinkManifest_WholeIdentifiers_fkey";
       ontology          postgres    false    222    2939    218            �           2606    38293 s   topographic_object_mereological_link_manifestations TopographicObjectMereologicalLinkManifesta_PartIdentifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT "TopographicObjectMereologicalLinkManifesta_PartIdentifiers_fkey" FOREIGN KEY (part_identifiers) REFERENCES ontology.topographic_objects(identifiers) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT "TopographicObjectMereologicalLinkManifesta_PartIdentifiers_fkey";
       ontology          postgres    false    222    218    2939            �           2606    38298 f   topographic_object_name_manifestations TopographicObjectNameManifest_TopographicObjectIdentifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology.topographic_object_name_manifestations
    ADD CONSTRAINT "TopographicObjectNameManifest_TopographicObjectIdentifiers_fkey" FOREIGN KEY (topographic_object_identifiers) REFERENCES ontology.topographic_objects(identifiers) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations DROP CONSTRAINT "TopographicObjectNameManifest_TopographicObjectIdentifiers_fkey";
       ontology          postgres    false    2939    206    222            �           2606    38303 f   topographic_object_type_manifestations TopographicObjectTypeManifest_TopographicObjectIdentifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology.topographic_object_type_manifestations
    ADD CONSTRAINT "TopographicObjectTypeManifest_TopographicObjectIdentifiers_fkey" FOREIGN KEY (topographic_object_identifiers) REFERENCES ontology.topographic_objects(identifiers) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations DROP CONSTRAINT "TopographicObjectTypeManifest_TopographicObjectIdentifiers_fkey";
       ontology          postgres    false    207    2939    222            �           2606    38308 _   topographic_object_type_manifestations TopographicObjectTypeManifestations_TypeIdentifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations
    ADD CONSTRAINT "TopographicObjectTypeManifestations_TypeIdentifiers_fkey" FOREIGN KEY (type_identifiers) REFERENCES ontology.topographic_types(identifiers) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations DROP CONSTRAINT "TopographicObjectTypeManifestations_TypeIdentifiers_fkey";
       ontology          postgres    false    2941    223    207            �           2606    38313 ,   historical_evidences historical_evidences_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.historical_evidences
    ADD CONSTRAINT historical_evidences_fk FOREIGN KEY (publication_identifiers) REFERENCES ontology.publication_sources(identifiers);
 X   ALTER TABLE ONLY ontology.historical_evidences DROP CONSTRAINT historical_evidences_fk;
       ontology          postgres    false    2931    210    215            �           2606    38318 X   topographic_object_function_manifestations topographic_object_function_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestations_fk FOREIGN KEY (historical_evidence_identifiers) REFERENCES ontology.historical_evidences(identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestations_fk;
       ontology          postgres    false    210    2915    204            �           2606    38323 j   topographic_object_location_manifestations topographic_object_location_manifest_link_type_identifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifest_link_type_identifiers_fkey FOREIGN KEY (location_link_type_identifiers) REFERENCES ontology.location_link_types(identifiers) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifest_link_type_identifiers_fkey;
       ontology          postgres    false    205    212    2925            �           2606    38328 X   topographic_object_location_manifestations topographic_object_location_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestations_fk FOREIGN KEY (historical_evidence_identifiers) REFERENCES ontology.historical_evidences(identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestations_fk;
       ontology          postgres    false    205    210    2915            �           2606    38333 j   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestations_fk FOREIGN KEY (historical_evidence_identifiers) REFERENCES ontology.historical_evidences(identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestations_fk;
       ontology          postgres    false    218    210    2915            �           2606    38338 f   topographic_object_name_manifestations topographic_object_name_manifes_name_link_type_identifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifes_name_link_type_identifiers_fkey FOREIGN KEY (name_link_type_identifiers) REFERENCES ontology.name_link_types(identifiers) NOT VALID;
 �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifes_name_link_type_identifiers_fkey;
       ontology          postgres    false    206    213    2929            �           2606    38343 P   topographic_object_name_manifestations topographic_object_name_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestations_fk FOREIGN KEY (historical_evidence_identifiers) REFERENCES ontology.historical_evidences(identifiers);
 |   ALTER TABLE ONLY ontology.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestations_fk;
       ontology          postgres    false    206    210    2915            �           2606    38348 W   topographic_object_provenances topographic_object_provenances_ancestor_identifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_ancestor_identifiers_fkey FOREIGN KEY (ancestor_identifiers) REFERENCES ontology.topographic_objects(identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_ancestor_identifiers_fkey;
       ontology          postgres    false    220    222    2939            �           2606    38353 @   topographic_object_provenances topographic_object_provenances_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_fk FOREIGN KEY (historical_evidence_identifiers) REFERENCES ontology.historical_evidences(identifiers);
 l   ALTER TABLE ONLY ontology.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_fk;
       ontology          postgres    false    220    210    2915            �           2606    38358 Z   topographic_object_provenances topographic_object_provenances_predecessor_identifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_predecessor_identifiers_fkey FOREIGN KEY (predecessor_identifiers) REFERENCES ontology.topographic_objects(identifiers);
 �   ALTER TABLE ONLY ontology.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_predecessor_identifiers_fkey;
       ontology          postgres    false    220    222    2939            �           2606    38363 P   topographic_object_type_manifestations topographic_object_type_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestations_fk FOREIGN KEY (historical_evidence_identifiers) REFERENCES ontology.historical_evidences(identifiers);
 |   ALTER TABLE ONLY ontology.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestations_fk;
       ontology          postgres    false    207    210    2915            �           2606    38368 ,   historical_evidences historical_evidences_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.historical_evidences
    ADD CONSTRAINT historical_evidences_fk FOREIGN KEY (publication_identifier) REFERENCES ontology_sources.publication_sources(identifier);
 `   ALTER TABLE ONLY ontology_sources.historical_evidences DROP CONSTRAINT historical_evidences_fk;
       ontology_sources          postgres    false    226    232    2967            �           2606    38373 j   topographic_object_function_manifestations topographic_object_function_m_topographic_object_identifie_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_m_topographic_object_identifie_fkey FOREIGN KEY (topographic_object_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_m_topographic_object_identifie_fkey;
       ontology_sources          postgres    false    233    243    2986            �           2606    38378 j   topographic_object_function_manifestations topographic_object_function_manifestation_source_functions_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestation_source_functions_fkey FOREIGN KEY (function) REFERENCES ontology_sources.functions(name) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestation_source_functions_fkey;
       ontology_sources          postgres    false    233    225    2949            �           2606    38383 X   topographic_object_function_manifestations topographic_object_function_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations
    ADD CONSTRAINT topographic_object_function_manifestations_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_function_manifestations DROP CONSTRAINT topographic_object_function_manifestations_fk;
       ontology_sources          postgres    false    233    226    2953            �           2606    38388 j   topographic_object_location_manifestations topographic_object_location_m_topographic_object_identifie_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_m_topographic_object_identifie_fkey FOREIGN KEY (topographic_object_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_m_topographic_object_identifie_fkey;
       ontology_sources          postgres    false    243    235    2986            �           2606    42311 j   topographic_object_location_manifestations topographic_object_location_manif_location_link_type_names_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manif_location_link_type_names_fkey FOREIGN KEY (location_link_type) REFERENCES ontology_sources.location_link_types(name) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manif_location_link_type_names_fkey;
       ontology_sources          postgres    false    229    2961    235            �           2606    38398 _   topographic_object_location_manifestations topographic_object_location_manifestation_sources_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestation_sources_fk FOREIGN KEY (location_identifier) REFERENCES ontology_sources.locations_raw(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestation_sources_fk;
       ontology_sources          postgres    false    235    230    2963            �           2606    38403 X   topographic_object_location_manifestations topographic_object_location_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations
    ADD CONSTRAINT topographic_object_location_manifestations_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_location_manifestations DROP CONSTRAINT topographic_object_location_manifestations_fk;
       ontology_sources          postgres    false    235    226    2953            �           2606    38408 s   topographic_object_mereological_link_manifestations topographic_object_mereological_link_man_whole_identifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_man_whole_identifiers_fkey FOREIGN KEY (whole_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_man_whole_identifiers_fkey;
       ontology_sources          postgres    false    237    243    2986            �           2606    38413 s   topographic_object_mereological_link_manifestations topographic_object_mereological_link_mani_part_identifiers_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_mani_part_identifiers_fkey FOREIGN KEY (part_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_mani_part_identifiers_fkey;
       ontology_sources          postgres    false    237    243    2986            �           2606    38418 j   topographic_object_mereological_link_manifestations topographic_object_mereological_link_manifestations_fk    FK CONSTRAINT        ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations
    ADD CONSTRAINT topographic_object_mereological_link_manifestations_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_mereological_link_manifestations DROP CONSTRAINT topographic_object_mereological_link_manifestations_fk;
       ontology_sources          postgres    false    226    237    2953            �           2606    38423 f   topographic_object_name_manifestations topographic_object_name_manif_topographic_object_identifie_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manif_topographic_object_identifie_fkey FOREIGN KEY (topographic_object_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manif_topographic_object_identifie_fkey;
       ontology_sources          postgres    false    243    2986    239            �           2606    38428 f   topographic_object_name_manifestations topographic_object_name_manifestation_name_link_type_names_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestation_name_link_type_names_fkey FOREIGN KEY (name_link_type) REFERENCES ontology_sources.name_link_types(name) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestation_name_link_type_names_fkey;
       ontology_sources          postgres    false    2965    239    231            �           2606    38433 P   topographic_object_name_manifestations topographic_object_name_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations
    ADD CONSTRAINT topographic_object_name_manifestations_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_name_manifestations DROP CONSTRAINT topographic_object_name_manifestations_fk;
       ontology_sources          postgres    false    2953    226    239            �           2606    44615 W   topographic_object_provenances topographic_object_provenances_ancestor_identifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_ancestor_identifiers_fkey FOREIGN KEY (ancestor_identifier) REFERENCES ontology_sources.topographic_objects(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_ancestor_identifiers_fkey;
       ontology_sources          postgres    false    245    2986    243            �           2606    44620 @   topographic_object_provenances topographic_object_provenances_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 t   ALTER TABLE ONLY ontology_sources.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_fk;
       ontology_sources          postgres    false    245    226    2953            �           2606    44625 Z   topographic_object_provenances topographic_object_provenances_predecessor_identifiers_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_provenances
    ADD CONSTRAINT topographic_object_provenances_predecessor_identifiers_fkey FOREIGN KEY (predecessor_identifier) REFERENCES ontology_sources.topographic_objects(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_provenances DROP CONSTRAINT topographic_object_provenances_predecessor_identifiers_fkey;
       ontology_sources          postgres    false    243    245    2986            �           2606    38453 f   topographic_object_type_manifestations topographic_object_type_manif_topographic_object_identifie_fkey    FK CONSTRAINT       ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manif_topographic_object_identifie_fkey FOREIGN KEY (topographic_object_identifier) REFERENCES ontology_sources.topographic_objects(identifier) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manif_topographic_object_identifie_fkey;
       ontology_sources          postgres    false    2986    241    243            �           2606    38458 _   topographic_object_type_manifestations topographic_object_type_manifestation_sources_types_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestation_sources_types_fkey FOREIGN KEY (type) REFERENCES ontology_sources.topographic_types(name) NOT VALID;
 �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestation_sources_types_fkey;
       ontology_sources          postgres    false    241    244    2990            �           2606    38463 P   topographic_object_type_manifestations topographic_object_type_manifestations_fk    FK CONSTRAINT     �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations
    ADD CONSTRAINT topographic_object_type_manifestations_fk FOREIGN KEY (historical_evidence) REFERENCES ontology_sources.historical_evidences(identifier);
 �   ALTER TABLE ONLY ontology_sources.topographic_object_type_manifestations DROP CONSTRAINT topographic_object_type_manifestations_fk;
       ontology_sources          postgres    false    241    226    2953            g           0    38012 1   topographic_object_function_manifestations_filled    MATERIALIZED VIEW DATA     V   REFRESH MATERIALIZED VIEW ontology.topographic_object_function_manifestations_filled;
          ontology          postgres    false    216    3206            h           0    38016 1   topographic_object_location_manifestations_filled    MATERIALIZED VIEW DATA     V   REFRESH MATERIALIZED VIEW ontology.topographic_object_location_manifestations_filled;
          ontology          postgres    false    217    3206            j           0    38023 -   topographic_object_name_manifestations_filled    MATERIALIZED VIEW DATA     R   REFRESH MATERIALIZED VIEW ontology.topographic_object_name_manifestations_filled;
          ontology          postgres    false    219    3206            l           0    38033 -   topographic_object_type_manifestations_filled    MATERIALIZED VIEW DATA     R   REFRESH MATERIALIZED VIEW ontology.topographic_object_type_manifestations_filled;
          ontology          postgres    false    221    3206            `   �  x���[n� ���*��y��Ҵ���4"�:�Y�8jQu��I�571��V�%���s�nZ?6����V�z#�����ߞ���K�����6��炏ZjAP����-l.�,����SG@X$�"-����Lh��ӛ�`��-��rN�S�j���y��r�Y3R0<R����>/��7��_�6���d{N��"�NN�A�s���9��k���'X�X�������厯�A)�����^I꬀�{L)��J�k�9�P��m��E�*Ӟa˲�!w6j�-u^�Q�eM q)d���1��:$\K��"�:P�4F��_N�x�No>�/�\��R3�t1}W
n��'��K�cழj`�;�]�1eQ��k+{#�r�)��J-��:?�R˳�4�6���$�B���&���ya�s?�>�
����7a� V�]���oSsHFwcFgQ�t�¡N�ξ�p�� ��A�S��w�W)���\-3pxU+2���>
���&q|��`������7��И� �Zsz�3�H�P���U�<Ɖ����}�"�ǕOȹ���G�HY�y`R�A1��>�n��fPC��N)<�ە�);�s�_���c�v$�{�)�4$
�3Y��g�
]0Yz �4��ŻV��S-c��TCu�c>�/���9�v�6�� /�����P��ne�/�����Z*nz<�j�,���Ə�,#xǠ�������      a      x������ � �      b   �  x�}T�n�0>����K�t�uX�5X:(��5��P\�m����$�5Jv�bv!���ȏ�h�h�X��ʙ�$� �"�-��b	���4�^G�x��]�KM�BB갏h��ӪS����L�0��O����=�s��㯦4-�_>SV]�eW�����5���Y搾Y�T������zn;u_��[Ulj]t���.�	��U�U�7ʁyvK]���,	X��!YIvt��֎���+i �ߛ�2C�^���z;�ƭfF��a�'�>�T���䂗"&X�>?�k,6�ڮ�s?�+�ǆ��ƑI��y��Ё-t]���("	x����-��L�xp�	2ߊ[Hkֵ.��6p�ۢ;��R���J�ό5����^,6y�',�$��. �9}|�=����BD����Z��)!�H;Sg8�(
��ho/��!�ZS��2I�f�v4�)����i�w���,����w�ؘ�i��P���,N?Lk��{eF�H��R��R-6�R�|.�4�3����k�g�,��X�H�FW��o�X�B��X�3w�l1 Q�:�xsa�B<s���A�/d2� <�9I{��^"}=gI%��]f
B���ľ%<WM��W�8��V�����Ғb�����$��H�1����^�j<����9B�y3�9�[l���,�}N�=��z�U��G:����Lo�� � �xr      c   z   x�3�Tv��O�I�M,(�2�T҉�Ʀ\Ɯ��)�9\&��>�y)9��\���n�%��@E��@5f��9�y�\�P����DKjN%�%���G�obU~yqU*��Ĉ�R�1z\\\ ��$G      d      x�eQK��0];��#���lB�TD�����b4�趻N�U�-���>�#F���O�vMBA����v�&l��-VL$�� ҹF;5�e�"������S
�j�~�8�(�m`�18�{�_-��ه6n�~����1�H���e�F�5��pl�5� @���*��ޯ$�P�/\Ӵ�KZJ�N�ÈSTʐM�8��������¿q�
�����W����Ѽ�Wu�Ʈ�N�L�u"�ݨޫ���!�рډ      e   +   x�3��K�*OT(�O).I,�/O�2�
�'�'W�%r��qqq ��      f   �  x��XMo�H=˿��&DJ���9y��p'F�ā���"�r�[Ï!�SƘ��y�2��.�?�6�i����}�%ZH��v� ����W�^���4�epጆ�F�ܤ'6��t��v���ߎ�"P����_��z��B$9�����O�LDq!��W�O��4�8ҡ�˯:M���_{w�I��M�Χ׿v�������v���=���A�^�D�I	��$w�,�=���"����v>>��5�?�B-�9MzhӹM"��N���k�6�^��^��v�X$"�S<��û��E��
�('z�}_||�|������8�\M�XBw��et��ؕ6�e�=2�y����h<:><�k���5���:��˷M:*}�^�k���.��ӱ���a����a^�n��>j?��gXP r�z}��:7���
F�|��*�g �o�0<M^�䌝�����_�56ܫ���t�{"��d�N��C&����8ɓ4I�B\#����9	�my��_ 9)��D��C��Ii���ؼ��σ�t�X*钘h�#��J�^�X`�27��z4��u�e�-n��$�ll�iwڍ�+� @�Q!���?�^=�3��J����=�ݫ@H��sʔ��vz�E8��'��o���T���_N���Ϟ��v���H�������>o�OD{5���q|)r���gY,9�ʭ':�sqkc���2��I���n��g�SN��
��_�JF�������k�i>����&�uF �����&��� �@���Z�.��7~xW�K�N�+��周�4Q��G"�9�@;O�O�J������N���xO�{\#�8��ƭ�'�|�E��I�Mݎq����)�X,1�i�_��a��.RwN��Z�Hn���˷�졀���'",�	{+���-c����Y�vx:S�ZHO���i���
Dh��ۨ4+�FR-��1�rN�+�V��*f��S���2r������ cHlvdV�����Ur���3���<��`쭽I��!`u"�H/t ��NH���C*7ˣ0�.����{șW��Ja�Ic�lI��ƾkk����a�&#�>~����\�����}�ECS�}x�����s�������je%o�%���8�͈��wxx�����!�I$���)��:�e��VuF�N�6Ф����&�6���>��QM@�� �́���i�i�,C�y��R7z����_��'fn��|~�����4�Ms��%��h	Z@�@�Tq?�9Wt/@=���Q!�1?!/����o��2b�+�9싊>�b׳c	S�&�Ȓ|� ����T`���<y����V�+�Ӄ�r� ����űFa�M�v�.���n;�v���tx�7��?����|P��*=|��~�.=��q��I>�T�T㱘F^��@M�,�MrYn���7X/��ȶ./Xs���*�̶�/�����O)*���4��`��D���Y!|�X�����Y�e\�j�c�<�	���1�"�Ɯ�킗�ol\�M�[��@���N�VI�z=k��ΧA�s�4h�uQj���lfB�踐�J�Fm b�.k젷˺�Z��O�o0�d���F��u��Ac�2�&[ �!��~_,ù��L@VDF0l�
�a����a��>]%�"�o�.'��P����P&�"hy2�̸��ڟ㳛_bE9/u�Ĕ�^g��t����P�)�N$�9��of����C��(�"��F$ T�߬v���t'���ۥ{�;[R��F��s���,�쭙-=�JKZ����t��ueKo��>�
�B5c�<s����a���_)�|.���H����#�?��|�]��Z�6��c���4+�R ��\�:{Mz�l3�k���L	o�|����N���M�P���A:MYG"��Xq����@BG��8t� �G�kz���; ���?��'X���_��A,��ΰQ>�sY�A=d"W��'�E��+E#�oh��X�g�BM��gs�{�xCͮ:�ab�TŅ��}E8/'�ܦ��ٯ��t���ct�0�e�\��¤)��)�HH0��K�aˊ�!�ɕ5'wʅ+!Gɕ��`��AG������K� f�z���OC�UY1�`ř%��Xae��i�8��6v!U�#�L0���u���QPU}��e�Ƞ�<U&�8OdR���P�xEN�K����/����(S0�?�:�JU+�� �.�9���5���P�va��������w':4�>7;�G�V�UTL�1C����������`ů���א�f����
� �d˝ǭy��%'Z���w�*Ͷ�f[7̶�l���vY'#ww�\I�U�|�I�D��C}��4���d�6.|#��3�L����!�?�n�aa����gѭ���֮*���f���t=ϰ[c�����U��i7x`�SM��1�x��ȼ�)��u˨�y�2ھ��d�{2tg:D~��E��(��}*���7��7�]v}v�O
�A��Z�ݼ�����z�� ���Br��˾x~ttԤG/��/�+���
`�+�Ay�3z�k��o_��B�ը�i<�{����̮����L%�b�&�]���˷{Y6L�9���h�R�C���������%/M�u�Ȩ����)+�W���Ack�I���:�?�w�g���t(&EU�Dlm�7p�ڕ��z��1ԤF�r?�����ݕjbSCע���7w���х�����˷�ց��Mf��:��a���>���.5�)�g}�	�>p3��ygp3רE/��F��%=L��=�a��hт�����[�r~�W*�������n��Z�������J��f&ݤu��Z̅djy���u(/E$;�繁�ڥ�)Z8��n��S��mP߿��|��{�: L�t^�A�m�F4׶qXfW����yka�ՙUTZ��jA�\�ʪ����Ǉ�g�� �����55�H�)@�D�o�'��,ɚ�d���������M      \     x�}�[�� D���z �^f�똖�_;��N�Z/�2�=�Ɨ���9��R��q��]t� �;1 ;g� ��XN��-�fw��q�ID�G� �IS#f6a6mp��)m!e�i#f A����'"����h��3N"z�f}!��4B����A:�|���<�խd#�@�=U�@�τ�k �@i�ںh�<�NV�9k��2����E�n3QA��/�:� ?���D�e�Þـ@����r�ƂQ���٬�$�q��8���R=���	�Qn��5�ڶ0i�S��K�!�^�r7�_&�1�،���=㲵O�>G��T^���A�q�%��eRG�o�KHn����� d$�၀�.۳2�繰~��~�	V�!�*����R��������_m�	����5>ʀJ���Bk��]PNaVy�~�|k0����w&7_7��Q�!_�����b@��������ZW(ǵ���}(������P�|�/�����5�#��mm��G������#      ]      x������ � �      i      x�u��m�0E��]Z�)JKt��?G.S=l�E� �9&�Ksa��E���7Z�CDU x[�FK�bE�ީ�jW���ié_��0��h����e�����S{���x��8�yN�9c�G��G����	��|H�VL*";vN��ߍ�������A���8v��1d�h/�,bhs�����%�{�#��T�L5�z2O���ݢ�Y:�Dv����)�#˒熏e�ʴݶ��� �I�u�����Z��Z�C�Q      ^      x��ZɎ�F�>SOA��,Mq'O�dɣ��Z���dS�Y�b��E��m�1�4~�������ںg�C.[�EdF��E$]ߵ������?�����9+����m?3˙L&����=��z@�����Ĕ����O��@�dѰjC �	������n��쵽��}-��fy%���xi�l��^�R��]�5v9��k�n/��-�s.�O+�|�;����a�t����g��[.����$y9�9+������dF�C� 3���/W߾n?ۋ�,�|c�zV��`����Ǽ�K�a����!�YQ6l-8I����M�8�Bn�
%W��kq���3i?�Y`�n��T���>���6P��j�����$���[0���'�5 ��8$||��z�m��1w,��}����e۠g�;�.y����"Wi��3����$ҏ��E�Xso���X�yN���^̑�B��4��myD&6Aa0��[
�S ��%\�W��6w_����}����[�{L'�&�3u��9q}GT$p�#*p���@E8Q*���Q�TL�}t�9��k��w��ꔶ_�}�n����|��S����`�o������N+�D8aoH�!���\�/lL��MzC��S��+��f�p���2 ��I.�5��X�>>�3��4�Œg/�b��r!��L5�m�pl'��G�5����?~��r��oz�JLo3 ��Fn��9�Ղ���t�U�֩\�T�S�Y&�$�!�y��%�/XC��^ʔЕX.�+�s����Z�9�������C��:�X.��'�L��30�B|p��9#���p`!A��-g6K�,������(Oy^�,����%�����亝�H��9k}��M'�^�R;��'R���O���ċ�.a�Ob���8S]��7�XAH�+�n�Q2qk5v���B�k{�R6m:P�@��W�}m�;�"�E �n�ﭜ�
���D���40�(�:�� _K�r�0�|$�B�>�0�(�^~�N����![��
�Q�L�>�ť\���,T h��qdZ\ �!1���:/�`��;0i�kf����J�i÷���ʲܰ3+QZ�VP������ri�]�Ծ�)/A��fC˛P�F�����p���\"G�p�����L�� }�����_L�I� \�Bf�@���F�Rd�b/="��`Z��gG̟�)�zΨt�I�C*�������گآ�a�WΔv�,��p�
��a�i�3q,�#%?J����n�B��Z#�Vm>��'����g��(uyaߊ�;q�s�$ ߵ<��$������ �.*8
�rd�im_�j�'�? ]l-�?�ڬ����x�G�<	��~�̊o_S���iFu�}V��8���iK$��G��H&�np]�G���-�F�j�X��q�����u)dUP�v��DqF"U�KBUr�(��z���g���E��*�WOF�D�y?G�L�3g��{��3>���t2�t�T9|�9�t�
�1i��ݷ-�ۯE��6��!�i<�8ZE����R^��o_(��Sw��[�}�g�I@�c����FF����-o�h`��r.g螧��!׋Z� ������,�|Mq���	Ũ\��,�L�����y���e�f� ƛ��O.jwhX���g����ҽI��"�8��:�{�Pa�B�{�5�c�O�(��h�_CfN�Tz�w���b���r%4�GvSlw_l�f� ������"��nI��-�91)�9��X��ۆ^A9�~Z�G��#�~��= #�0�ˮD?<"��R
ĭ����m����iH������g/eF~yF�ֺ;kq��g����/A��P�$�g�nf���mwV�,N5�8#&a������F�r�{U�!�����OJ��R��\�|�����zV��E��<�(\��:��!�`T���e��)�͇V@	#����+0+�����i�o��d�T1���'G8P[��|�d<�֊Q}
TYR	�1�����Aa�y�5K:��� v_�
1�Ec��=���}�YU��+�8l�s��P1-#�x��>Ũ�����O�	D���U6�\w��Z�ʤ�e����G5��b��W2WY��+�<�Zj�N���t��pgԑ�B謊RM�tr��8g�&P����T�K���xA��7u�.��H/-�T���ǾצD�B�C��ͻ:�K��S�m�S�RB+��ej�'��By����hd�%���޷�~���
S��֍<4C�.e�V�O<'��Rbm�"�|�F+R�Do��O�@�)����X��o*^��F��W������C�ka�y_n?�Iv�վ
"�cD�D�Kz�`)_��FC�yv+��Pa�z�{��_>��="ṈʈR��"/��6�Ko���ktN�N|+
̵�s�6_V|�MЯ�H�@�~]7�^�������r�= �"5Z�:�z8�P��@��#�Z;�1'��9��%�j�b��X���0�>�/�b�0Ի�~.�bu&h.7����z�8�𽚔�9�M8 �j�>c���+��DM/r���ܑ�����fHz�g�{6fj�W��c'��e1xΊ�`�^X1�N�<~>�s6�+C�R��a��������82���S ��~;���Cz���s�J��4&�t�`r|e7�"�F��n|��:��K�q栭��~-�L΀F�	�)���F¥��*�8�EM��7Cق�@�Y~n�'@h%��f�!Ǭ��h��KY� �Ҙ Cvl%��O7�-�gS#�@Fz��4AOۇN�9�p;���#�o�����w�� ��_�F�t��n�c%�����٥X+!/S���i宕��f�h�DUv�1{J����LA�g%ё�xQ�Jl�AQ�+�de$�C�� �i D���i�DuNi�Ξ���QFH�i�� {6Ŵ��Ro-�]mث��|1,%�rt�[ZJG ����O���z�F���y����[݈H��������UKm�W�)q�c` ��i�/�1d�6�cpb��J��4Lj�%�0��e@:.�9L�QL��=�X쨋O /xG��X�~c�(��C:Q��r'2*ފ�C�pb��|0�?-J��qӲ�4N5�>@E���Dj8+qG���璕l��}%�K���9p����.#������|��1	G���Fue�;oX��߲.�҇?@�'�ᤱ_7�;�мӔ��V��n�?/C��1�ɀ�;�s ���.O�ݑG��Q�<F����{�I�+��j����I#���Xn���m�[��2��Q�١�"HS�G�㴰���q�9[�7�Fx�'�l�ƨQUL5�v�}[���Rf)}D���㙚�Ay_<nCH�+�QԘ��Z8X��x���х�;A"�&M�B�J��$�?=�,�KB�ό�Ő(�rLB�x��8�"l��ȵ�/�
���dD�e����w_�;�"C0,H#�󘵚�r5���@!����f��H�kG't`��M��eߧ?��4d�s�O[q��1����g��������ջj��mh_Ȣ�5�0˽v�h��g<b�\#��+'�*�~ש���O�B�io���¦B����R|*�
�y�P��!܊�az1��fV������k�Ӓ��h�7�����iL#�v�{�3���ާ�Eo�a���@�_�̯E�;����"˴��#�z��� ���L�h����a�=�W٤�ѫ����F�����o#s�ao��0��?@�H��u�Z�Q�f�	3�)G��+�Т�y��:�w:�����Ҁ&LޔR�#��%���Ô��w!���|��.�ڽ��H���ߜ^.d�~h!��(���.�P����a��[�_V�P������mT\1������ :ԩu	�|����BT�S������Z	݌��j��}��S���Ч�F�h�[V�e3���>�4@4��^�l?#�H@�%�j8��-�\�YIz��k0]�o(q����ĺ^��O�=^�oO.[�1���D#F (   Zփgn��}�����X2��GE�{����^�_�<z��_���      k   �   x�5Qۭ�0��a�J�+���縆�RllhUI�lV#�(�d$-� ����5i�Y�)���>5o,�ꫀe�]���lJ��Kc+�a��h�M
�I~7�,�Gl�U6���ar�`s���s�fM�c�U�ǲ�L���N�|���#W�q��n�9N�V�Je���T���tQ�nMs�u��a)��x~����]`��^��њc��5��ӊ'|�9�#�✼�����ڸZs�f^�9�Ny���?f��T\      _   �  x��Xٍ$��V���E9���v�fJ��2�� ���T�RHe�b�Z��~ʜ!���ׯR6v��Sc�z�?3��B=�?��
ɡ����O�
(�{���\�P��S����g�T��w����������� O�7D�Lh҈���O��жJy`�������<	���
������B�OH��'��:<!��gE4�.�LZ�����z]r��B�F��3oOn�!B`K�.?MI� ZHhߘ��-��� )�jBB5IJ1FP�VX*y;k&�ռP%@ޟ�2�:���C�2�:-�g��L4�A2D��|dZ u>Hb�"�����Ą-7u�L}��>�'}`N��ЅRe�YN.��I�3�@�*�r5è�YJ��=�oa�d�6��3�f:��2�*8?6�0�UiZ��
$<�P0L^�9IhQ3k��H�\�I��9�PW��O�k�ڕ�%�sV�5��m"f٪'A�m�X]ԙ�����<3,���/H���m��ƴ��A�i%IO�tH�;B��6��M���JB�D��D���nȤ�CR�6��&��(YYѠ����>��,b��e�~Νc��ݗ-W>F#r����=�}V@�JF-t�ߴ�MK��Bz�����cR*h���f|ڡ���H�W��;u`�bf� 8�7�jT��va�v�1��ahu.��yK(apZU���X�.��n�Y?X�	}����W+�`�S^0}wi�p��~ehA�(�PF�1l�fz"�t�5b`ʕ�]�T���	~s��U���)A�ׁ��d� 򷆘�po�d�]W;3���&(�͘&ar��"?V�4���:�~� ���uT�������hz-_J����3}�**�/TU��݅����+GnL��&3�/��~#�0�=�+WW�����v����B�%S�
6��FQvc0E���WV�t7G�<1��ģC0y�L�{bB���_ �`*���aȉ�ӫ.ܚ;�1��5�ݍ,��e�����w�4�E�~�RS����y���HX��֋�B(����[=�/`XN���o1�u ԯ���j[X�����P�P\1��|20����jvy����#�-;{�/��y�	̖�F_(0���w��m�E�)d���i<o���/j7��G�`�QX�=����i�=/Ս+%�I7��j(f}a�\n�'�!Bw�]������d��Wi�m� �V�� ���_�s0�񳪟T���n����F�2�F���8�]5��;<���P���Ώ�����{���|�~�[�h�/����-�m��3�0l�x����ܔ�;���]n�J�.����7X�=b�۞���j|Y*�L�t�|li�=��|/�-�aO��Ks����.Ϭ(�r�fY<���N��AtWǨ�~��o��8�5�*�s,T���@�̺�4i��]ab��Fϰm(w9�����0mx�*��-X���=	v�f�@�:t��,� &X~���#�K�n�$� �KΖ�}7&";�Z����d3g?��)��1�׶Y�7a2%4���o��<'�v�ӧ�|��6��ȩ�����i�<d�	�+J/o�����JH-�ω� c?'�V���4�#���a�R*�h����Qz�c�G��F����~~~�xs2Y      m   l
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
+��9o���G]ʂ+IԨvdr�`���4n-Z�e�Y����QkG�	��UX�g����޵�*6w�����S��V�?HMT��Y����q�d��      n      x��}Ɏd�����+�M7�[���Л^ע���>܀p���j�[A��]A;e�HI�����P�*��4�6�c4��ŗ�����ϧ������?N�v��8�c�O%�y�<����{5�(���C0N�R��Z-��v�At��,���M|P���ǔ�(}���[�m<m�qܯN��)9
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
��5O޾�~$��_��w^��h���ϴ�w���p��׵�c���~�eSb�\�;����T�Ҭ�Mگij�ؠ<	��~5�^n��.�Ѷw�W�P��V��'����"��"��������=��������g��8݆�ȿ�#��4�\��_ l��?'�)�^W�e�����5�?-�k��`C��_S����)�!�;]b�����OԔw�i�y��ñ��ۦ �R��Z)91!p����������      o   �  x�u�AnKE�1YEV�lǱ�%���HD()Q Eb���Q������+�ʝ�?����^�/?]�>>|���zs�<hضp�����W�a{[�)zh|�Uw'�����oJ�����|<�֏vݗ�k���c]:�g[���s�ޟ���������E����L�<;�g��i>;M��a�`~�q8s���~���4�2=dd���Ιs����4M���1�u�A;����7d�������a|;�����z���_�:�p}�\e��'��Q�nv����"���Q�m}¬M���!S69e�և����2Y�SN�3�>d�&gL����_���M�h��4�ii�F�q��ḧ�f8|U�B�����[�f��L�R���y��KIk&j���xKέHO.�ǭ�)LO[z�gkz������G*婚�YNO3=K��Lυӳ.���������N���z!��eB�;��W�R�t/
 �2�X�6P�� �~���ɷꗾX?���]���9�Wܪ�_��J��
�qkz
�Ӗ���ٚ��*=��i�g)=��YNO3=K��Lυӳ.���������^��
�qkz
�Ӗ���ٚ��*=��i�g)=��YNO3=K��Lυӳ.������|�����zs�zs��=����.�枫��������]\�;^�{�6w�6wqm���ܹ�6�pm�hm��|��A��2a>nMOaz�ҳ0�����JOaz��YJ�fz���L�Rz6�\8=�Rz��YJ��GzEz���JYrA�[������eVW�Ƃ,�2��V-��ZW�ZT�ZQ�ZN����k!��ZE�ZB�Z?O|C�Q.+�ǭ�)LO[z�gkz���������l�g9=��,�g3=NϺ��fz��s�-=oE��0���0=m�Y������S��6z�ҳ����4ӳ����\8=�Rz��YJ�7������?mYS      p   �  x���[n� ���*��y��Ҵ���4"�:�Y�8jQu��I�571��V�%���s�nZ?6����V�z#�����ߞ���K�����6��炏ZjAP����-l.�,����SG@X$�"-����Lh��ӛ�`��-��rN�S�j���y��r�Y3R0<R����>/��7��_�6���d{N��"�NN�A�s���9��k���'X�X�������厯�A)�����^I꬀�{L)��J�k�9�P��m��E�*Ӟa˲�!w6j�-u^�Q�eM q)d���1��:$\K��"�:P�4F��_N�x�No>�/�\��R3�t1}W
n��'��K�cழj`�;�]�1eQ��k+{#�r�)��J-��:?�R˳�4�6���$�B���&���ya�s?�>�
����7a� V�]���oSsHFwcFgQ�t�¡N�ξ�p�� ��A�S��w�W)���\-3pxU+2���>
���&q|��`������7��И� �Zsz�3�H�P���U�<Ɖ����}�"�ǕOȹ���G�HY�y`R�A1��>�n��fPC��N)<�ە�);�s�_���c�v$�{�)�4$
�3Y��g�
]0Yz �4��ŻV��S-c��TCu�c>�/���9�v�6�� /�����P��ne�/�����Z*nz<�j�,���Ə�,#xǠ�������      q   �  x�uT�n�0<k#�&"EI�H���è
k��iɢA��[��#����K�A�D�쁳��ΐ�w��}8��
UfL�$���a��O'�t������*��˫p��m�����c_Ѷ�O�L���+kZ�8��<�5����&��Ϗua�n�Q�0�~Qv�����W�Zٌ��/���4��p!�m?��z(�٭ʗ���j�n��q�G�*��~A�ck��Q����%�4�()�ܬu�����5�û0 ��2����p9"��'W�Rn�85vu2�X�R�Z�� �ӱ������R������>`M$:�F�*�E�a"��xQ��$�q����ɴm�%�ɘOκ�Y7�{��,*]��\���pӑ<��ϵ���XS���|�����!;��3. �$���sC�^7k
1�n�v�4���2�ٶ��!�޽@�=2o��_�G���4w��w8ǦR�	)��z�g��m[c�����K�0�:�U��DϽ��o��^��O�V+�A}*U���T-��<�G <��f[a6�zj�Ƃ�L;͗�,��0Ò����� ��(H�@�0 $!���A�2Ia����:!�ן��{J��齟$��E��ᙪ3t_2��bn�ն�[�tJm�b������c�!�Ĝ���kP]�+����b���ֻ���M	q�Kt/��<?���чO�򖻽9��� ���      r   �   x�Sv��O�I�M,(�TF����db����)'�ɥ�����	���}2�RrR+9a.e����\�rCK�Fd�r@Nb����'�37��YSSs��\ʎ��U���U����} �p�`<�=... ��B�      t   �   x�u�M�0������w���DR�#��%�0�-;�,�b���^�7��r�$]W��1�E�١hj7A��HChA(���[eA��o���/��FvHw��%�-��wS�x4k�\��da-i-X���`+����h��?�Ț� �z�7��Íe��藏�Ms-��3F��?Vh�.�r��X>moӧ���~��      u      x��Zێ�H�}f}�~q=5��yX��c��\�_`���E�D�Y�H������Xc��ӟ�o3~s��d&E��u������bd22N�ɒ��<S��"W���)g��9�Z#�Q"9q��ҥ'��y璟_>}z����0��̙F��dV��pk3�L�|Z�\z���8=��u�q˶�"����h+X܀̅��enu�)�O�ݼK'S�J�Tm�V��Ųtէ��(�bV.�+�]��0v���j�E��7F$����Q�-�6��
��#��L�\Ie�k8�`]��^qV��b�z]^�������ͯ���oy������u�R�jҷ��8eL~��Au'�˲nq�Fg٭�?)�MqY����k�.�΂�xn���[�1�����b���.?+��Ť,���6}}Q�|����jz��3���%�=���iq��#�m��2n���`ss�e޸�K��&}U.n�]�!�'5��HǛrAKn�+�/GmzV/�X��۴�\�9����Zt�L��G��O�՗n9q�����|�Kz^߼[���^���xZ�G,F���j�kW���E��,�wZ%����Udu�Ƃ4,h�yK)�Ym�́�gE�t�&=����72]&�=������"?b݉�s�-�x8xk��� \�5���M_��M�X��//�ͼ,F����{��Ţu�vw���m2�@��89�2�	�?�g+̸M��]���T4������P�3 A �����y�wJN�a;?F���=uM=Ez��zV�����a�\")H�qt��2D5� ���Sr�O�du��r��x,!J�F��҆M�͹2<S>NN{D���ɧ�6���Pm�>�[��޼��b8Y�dq�ns���\!qt��.9�ΙL~r0�v� .ł����e"��OݦĦ�;��b��w���Bp���Y�@Y%���U�/�ͧ���[�m��6}9m��[��aB�l_D�ޖw7ޥk�\/sCG��gB��3�	�ߊ�W
�	�Ho����a���0��й��w�Ɯ����H��p�����qi���5������W�D�hE�	+�#*B�,n�`���� e������W�����G7��A���8������f��HP�`E�	�㙕�c�
d�p��f`!�ˊL ��AY� �$�Sd`����]O\����؋̢���,v ��Y� �'�Q�{��(��gϟB���bL2���L�Kc��`�����ӈ������]������/k���}?XKh�u��Gn1
�Z���Rq�Hx ٨��:�!�M��, :(#�K|[Z=U���XV�䵻*6c:r�l��B9o�xS�A��H�'bI��b5�����(�y==�=�/Q��]Ac! �`J�,�4��(q�<Y���)�_��TIK/�|��C�h�o�bq$: ��T(2l�l(���$���p�y�� g$� �6�7>r����D�(S�Y����t�8Ѐ%�h�9ف��l�D�'}�O� �t@~���m�
��|���e�hZ7P��(:�qi�ߨ��U֤В�t�ҟV��;�Bu�g���APf�]CP�\Ѓ��䝮�E?t,6@M�ԓ��iS�[�zrWSIV� �t��2�p��R��J&�(��5�M����m�s�k�絫.h�I��^xK@��t��f<�,�P�Zb��w�zVO��r����j@��m�Ku������D���#(�^�<�L�
�ov��A�:J}���H�ؖ�D��<�y�
H,ӫ�oZ��9���ˏ����R �!ґ�Y�8ܠ�$��U5�I�d|z�/���(F�����_13T�2p�岇Cn�|�BƁ(w�9��In 4�#<�ha����,`hZ�<)�u��zX_��5l��B���I�F�%e$�T$��\D�G6�g�nd5@9RR%`�r:�^�p�۴�r<���0ڴ]�^��;��xH�J��\�jɂ�����-(ܧW�e��������D���
8y^_����`ZL�W���"(QO/0���ϳ�����@s�-�y�B����T.�W���N��6�S�3�֦#P�[,G� �P�A��Y���5(���YB�#�Lon� � �eP��22�X�[����(;�k����ɴ9�f��H7�ZT�X6}Z���x��<bbat��lGH,HX%��[�j��3�?��_�Ų]��X���O��� ��n���@HA�������&�%P"*%��)� }H�iR�FC�E��F(P�~���j[s�?eE�ͤD�pBn,&�tg�M�S3<�c)^���@��\+�8�)D���p|�ÅW
�B�i(n5$LL�@�D�	�7C���:0q�d���S�2����-� � ����=���X��tZWdQ��ؒ����P��6�j5-��2uvi�T�{�a��2&�@��h� #����6|�ΈV0"n9`㐉�md�`��@~H��,�i��%7s7��+�1`�5Y�>��=4(k�	��V8@q�Rvr�x[#���I��^POP8�\dCz��� �z
��P��mV�_0���{�pL��=��1��\����S&$D��<��@FH{��X`��r��K�����]A;GRE~D����ջU��P����� �!��MT1�{Na���~����>�P*$5e��C��j���&�cT�f�)3,����et�ĺH�w�`���7�@��H�:�� ���7���Q'݆$i,]��� )	/���1Y�_;��f�`:*	�B�h''�"��od��@��3&U���8շ�������^$�;����Ժ�~�>�����&c��\8�#@��wf,<�3�N�Q�>{��Fbe���ĊdC��
�����QS,�~�wy�+�������Z&6P�#0Q��'�4��
�����2�NI$洺�.��JQA��6n��Qp�K�~�n���t�MP8����F)�gL%?S�E������!��O�qo�Z*4{���>�^��L�mr�ޜ���§�gEn&�wV�Ճ����Mqdv8����;T2���<�`�Rܸ���/�w1��0a���BC���,��?�lTצ�F���s玨6� <t�Y�djf 灤�I���vL%ɞ5�hM��@�0J��PI'��F(i�5rN}�K��H�f%�S�&Df�^���/���ˁ_�� ="�۞��j�5�\���k%<l²h��ӂ"z�D������Q��:�մn�(��@DX,�;~��7��A�(*h���a���|R�@36�)9����(%x���帘�	,�5-��������;�9	0?	�/�
��p7���lVWw����-���ga���w�����JW�0�e!��sZ�H}�o�)��C��E�S��|�;x�*
fp�����J�X�I����ӳc�d!��;�<��#�4��**çH����4���NЛ������X���&-�W��͛m�CA��y�ơX�
�b������#��J}Kۏ��f�c��[�qwp�&��e�ed7ICv����3@l@�'��ݸMg����-��z���ng�I}:�O���ѣ���#���y��+�@�Tp�Ge��r�u��lh#�T�q�9�!��
$ni�[Uk�{�|����:�&�A�@�"�X2w�rZWi���sSR7-�jƃ�xz�����"���Ԗ��E]�,���wLj7X��0�]#���2�d��3$��Q�,����~��L��� �8@F�0A�%/���7^E$?�K֫�>c�'i���b����D-N�<yQ�e�C�i>���
9|�i��v��c�:���݉^�#���5C�a�v���B�D�a��(�93�hr�4�[�5��t��������bR���٧�t5����Ӻ����J+��2R������_@�j�,B���nZ4�ʞ��ZT@ӭ��H��%F΋�g()���~����/?7���o���~�1� �  �)I ye�t�2�b��E߸
��5_	%��8X��ǐ�G���Κ�$j%}����0��ڛ@(*D.�*�CG`G�I��P՝�ь
#3��5Y���+ķ�Q��v����ʻ���3
sn����M�t� o )���~=-�;�/�Q I�P�ts��p�*G-,d�Xl�:����W�����Q�� ^�׸\#~�G
���fn��������C0��[���/���QD�>�4߹�1�/��S"�q+����&5ɠ*�I7tY����:�y�E4e1D �E�3�K�����/w����U�7D@�AO�n��@[�\|���2����o�!i�rR^L�zY����Ʈ\,[b��]�f��h����G�ՊxK���L���ƴ�9*IAc�2�)F0�%8����􁝄����#�ӗ��H�	�9?��0Z���n��TAmV�;��"��ފ�@&�̋�_�4jY��BX`Y��e+@�_*�o�b2���=7)�;�1�H��V[����  �o��.˿�շK�0���eB���	Y?���q�����9;��ۍ&c;����t��jQK�xS��4nQ�z������W�y��j��k�wQ.	�S�_��>���*cϯߏ���2A���=�������Ŧ��R�DR�Gb5?�\�w�.�?q���n�8k!�W( ��@��4�sekkK��7�`,�ګ����cp6؅�y�0��8GM�P�=���y�	��C*d]��3w�����QP�2��H�Ϋ�C��c��I����{Q��n\�c�{4���y���K)�g�+\I�Vϻ����=l����\z���2}HSQ���;�t`t����O"W���5�g0F4� �.U:�岲
e	~�P�/'�W�����:U�'t�W��u;*�?�K�����*xO?���J6���A��5W�P�(yǝ���5��;�$�!�W�պ�q�N�_4�]�@t��|���X�;�X�$
+Mc�4J���U�a$C9��k�����Ⱌ��d��z▛�����Y��ǣ�o[O���=m�u�ݯX��ԍ�WѤw�-������H��xX_���/��3��ƹc���O��n��4%�:�/ʦ).]9�xN���[�����v��������UF��S(��o�QK�&��%sؒ��_&���Kܻ������'���YUN���崌������㣣��r��      v   )   x��K�*OT(�O).I,�/O���'�'W�%r��qqq  �t      w   �  x��XMo�H=˿��&DJ���9y��p'F�ā���"�r�[Ï!�SƘ��y�2��.�?�6�i����}�%ZH��v� ����W�^���4�epጆ�F�ܤ'6��t��v���ߎ�"P����_��z��B$9�����O�LDq!��W�O��4�8ҡ�˯:M���_{w�I��M�Χ׿v�������v���=���A�^�D�I	��$w�,�=���"����v>>��5�?�B-�9MzhӹM"��N���k�6�^��^��v�X$"�S<��û��E��
�('z�}_||�|������8�\M�XBw��et��ؕ6�e�=2�y����h<:><�k���5���:��˷M:*}�^�k���.��ӱ���a����a^�n��>j?��gXP r�z}��:7���
F�|��*�g �o�0<M^�䌝�����_�56ܫ���t�{"��d�N��C&����8ɓ4I�B\#����9	�my��_ 9)��D��C��Ii���ؼ��σ�t�X*钘h�#��J�^�X`�27��z4��u�e�-n��$�ll�iwڍ�+� @�Q!���?�^=�3��J����=�ݫ@H��sʔ��vz�E8��'��o���T���_N���Ϟ��v���H�������>o�OD{5���q|)r���gY,9�ʭ':�sqkc���2��I���n��g�SN��
��_�JF�������k�i>����&�uF �����&��� �@���Z�.��7~xW�K�N�+��周�4Q��G"�9�@;O�O�J������N���xO�{\#�8��ƭ�'�|�E��I�Mݎq����)�X,1�i�_��a��.RwN��Z�Hn���˷�졀���'",�	{+���-c����Y�vx:S�ZHO���i���
Dh��ۨ4+�FR-��1�rN�+�V��*f��S���2r������ cHlvdV�����Ur���3���<��`쭽I��!`u"�H/t ��NH���C*7ˣ0�.����{șW��Ja�Ic�lI��ƾkk����a�&#�>~����\�����}�ECS�}x�����s�������je%o�%���8�͈��wxx�����!�I$���)��:�e��VuF�N�6Ф����&�6���>��QM@�� �́���i�i�,C�y��R7z����_��'fn��|~�����4�Ms��%��h	Z@�@�Tq?�9Wt/@=���Q!�1?!/����o��2b�+�9싊>�b׳c	S�&�Ȓ|� ����T`���<y����V�+�Ӄ�r� ����űFa�M�v�.���n;�v���tx�7��?����|P��*=|��~�.=��q��I>�T�T㱘F^��@M�,�MrYn���7X/��ȶ./Xs���*�̶�/�����O)*���4��`��D���Y!|�X�����Y�e\�j�c�<�	���1�"�Ɯ�킗�ol\�M�[��@���N�VI�z=k��ΧA�s�4h�uQj���lfB�踐�J�Fm b�.k젷˺�Z��O�o0�d���F��u��Ac�2�&[ �!��~_,ù��L@VDF0l�
�a����a��>]%�"�o�.'��P����P&�"hy2�̸��ڟ㳛_bE9/u�Ĕ�^g��t����P�)�N$�9��of����C��(�"��F$ T�߬v���t'���ۥ{�;[R��F��s���,�쭙-=�JKZ����t��ueKo��>�
�B5c�<s����a���_)�|.���H����#�?��|�]��Z�6��c���4+�R ��\�:{Mz�l3�k���L	o�|����N���M�P���A:MYG"��Xq����@BG��8t� �G�kz���; ���?��'X���_��A,��ΰQ>�sY�A=d"W��'�E��+E#�oh��X�g�BM��gs�{�xCͮ:�ab�TŅ��}E8/'�ܦ��ٯ��t���ct�0�e�\��¤)��)�HH0��K�aˊ�!�ɕ5'wʅ+!Gɕ��`��AG������K� f�z���OC�UY1�`ř%��Xae��i�8��6v!U�#�L0���u���QPU}��e�Ƞ�<U&�8OdR���P�xEN�K����/����(S0�?�:�JU+�� �.�9���5���P�va��������w':4�>7;�G�V�UTL�1C����������`ů���א�f����
� �d˝ǭy��%'Z���w�*Ͷ�f[7̶�l���vY'#ww�\I�U�|�I�D��C}��4���d�6.|#��3�L����!�?�n�aa����gѭ���֮*���f���t=ϰ[c�����U��i7x`�SM��1�x��ȼ�)��u˨�y�2ھ��d�{2tg:D~��E��(��}*���7��7�]v}v�O
�A��Z�ݼ�����z�� ���Br��˾x~ttԤG/��/�+���
`�+�Ay�3z�k��o_��B�ը�i<�{����̮����L%�b�&�]���˷{Y6L�9���h�R�C���������%/M�u�Ȩ����)+�W���Ack�I���:�?�w�g���t(&EU�Dlm�7p�ڕ��z��1ԤF�r?�����ݕjbSCע���7w���х�����˷�ց��Mf��:��a���>���.5�)�g}�	�>p3��ygp3רE/��F��%=L��=�a��hт�����[�r~�W*�������n��Z�������J��f&ݤu��Z̅djy���u(/E$;�繁�ڥ�)Z8��n��S��mP߿��|��{�: L�t^�A�m�F4׶qXfW����yka�ՙUTZ��jA�\�ʪ����Ǉ�g�� �����55�H�)@�D�o�'��,ɚ�d���������M      x   �  x���_r�0Ɵ�Sp�˲c�.��vI'�0�ܫ��Vr$4��B�3�O>�
(�@
|aԟCS��hߺ�i��hc4�� �D�W�ݯ6�Q0P8ϼ��*-��j�+W���RsZ��f��՚�����䧸jW�C���:�U�7O9�,7C�)�����v���,�W�Q␰νRn��h;R�͹�w���&��F�P�S�c����
�F�X0-d�q�N����`��z��,4z�a�4���4b
>ꋬ�\	wŇq���1J��YF���H��dx��ܝ�u�-�93�Ă��*��:c�]�@,}jv$��5��۪�v�n�<�}��KtN��6��(�rOwq��G�,h���8�������i�Uyn2�Z��/n��x"�[4W���]�M(ϧ���̉���{kv�3�g�ţ�^!h/g ���L�B!7%�w��n6`�cA!jG�Ofv˘�
��|�䈍������[jR��Hn��ks:�ȵ�=՟����.ˡ��;3����D����W3{Z�+K^{(,w���aģ}��Z���D^9b��[���sY4X����ϭX���-����%H��Y�S��xM�u��):t2�VB?3��;�����f)�q؂�J��'R�4@%}G�*;I_/8�n�)c�����*���w&>H_<C�j�p�?#�)>(�2�߿�����}Y      z   �  x��Y;�$��Y�Y��;,�ɓ3�'c1¾�8��5t�򄹗"�̪�"�,����'#22��;J�ew>�?��~��������=U���}|�DX�}~��F@s��,��~��H�]pa�&��FٻL:1��珟���� �H6�����v��.��oq>DT�?�'��t��?�%�D��@�eJ_&<#jG  e_�u�k8�e�]���R�[�@HBPrc
��q���}�շ	:�����r���A�M4�������׿���?��!,9��n)#�j[Ძ��rF�T *� :U�}T���f�����#�v�j�
�DXK۟���%C�L��M��c��/)�S2�����o��FE	���� ���' C2��+�Ƹ�K�
���(���<,`u�K�O����=߮_�ɚ���#�Pá��)nORh�AP��!8�^ֺ������(��KP���@\�2z�yE��H[h�;��5A	�q?�J�����-zFF�.:x�-2����VGĮ��E���]`J��o1��X8M@��A~"[$w�h̎�wx�tmE��U�W �?�4�����y�΀ec�5M����/||~����ځ(�>����gYa�p�-3Ǒ|��j���uM��i������U��ޒ�&Ot�������^xM#k�j�<�C�x����d��Me�u��v��>�܇��l�q�y�h�b��s�Sep��}���N�����JMp��Jf~�<d�d���4�	�&�}�)t;`���x�/���9^<�I��e��~ז&x>���S����8|>��O���(���~���l��O] � �1NpV��i��usH����HŚ&�`gȋ([a��;��<�W��Z�0�`␊����`�!�����VK'�MB��!�SM振 0Q�~��h����KC/蟰xo�dbxY�a}�/�T����l���O`튙[R�;���唯@4�r;buF�_�-Y(��^�~yt�l�B�n=P�K&��<����A��h-�V\���-�Ρ�$�tϣd���.���AuՇS��RU�׵��m	�Y���ݑO+g_�V�����>H�2�n�._[�+���F>���ʠ�[q�uqep��a~��2Xl�B;o�\,�l�[�Y���L'�f�	t�6UQ$Li'�#V�A��Aa�oW����-0�:(d���-���޾��P��K�n�ƌ���΁Z^����a�B�ِ�p�~����Z�(�7Xq�6��^z�ǭʡ���ѵݰհ�@���Y_�Df׌X>����@�͈���y�*�&vPǌEۢm���Ϊ���	n`�Z��j߼?vP6r>rl�㈑�+�8&}�بO�4�.=����ec��m���F�*��O��[JE�ƶ��K}|��j�$�治�O��StF��6�9U)SV�Z���4n����џOM���X⼨c����PҔz �tV��	PGᩄ�N�A�>�0��03�p��fn��Pn须ae��,��*-���Wͫ�t ��,��j/��k��рO�������i�:%���j2��RBJm��u����	)��r��/���i��
�w1��j�9��v�9�BZ��W3���
��`<s���X�݌��[�W�����֤�0��q�������A�c>1�Z�a���{E�ZL�&�Z��,�&1'����Bn�醃�q��-�9_�}����ݠt�0�l����!^���rB���%<��C����〈HY��ЯC�@;f%Z�u0����[&�ү��šTyjօ���GS%���B�FcK�S�fꕃ���{e;��"���ÑK�������Y0A��h����E���}�����+�|T���j���(_�h�.�j2
t.U�Y����,at6�FbB�&K>n{\Wr�V�%��=�Khu��}������}Q/
a�����r`��ZԪ�P�Ω�SM>@S�
��7�RK5�tU�BK���y0�Y��<Q
�F$l�?H��_(l��r�F�?}��a|����i'qS�6 ў�cV�R�6ю�{~��R�6�~�cV�(i�jP���r
%m6���h�^�S�3h8��Z����S5fE*%m�v� �W��1J�l�϶p�j�3h1��lm�'����S���gг�]d�����w@I�C;��O�(+A��_�m�K���      |     x�e�Qn�0D��ì ��wX����9:�ثT�*Z���9�Ɛ�4��
�"ri��ԅBo�l��P�ET��~�����(*�Ve��E���EU��8�m� !l��?���L��͖k]Y����\��4���k�NkI�͍3�~�Ä�؎*��^h]���&%�O!�.~$A��)!)q�^�dRB��݆�o��|(�Q�#"s�-��>�djh�(�m�����:�'=�K��aB,���N��<���y]���Ka�      ~      x��[Ks�F�^���UR�x�zuK�cg,�QY���u7M�E��y�0�؍k\�7x�3�����5�� �&���n,'���ӧϻo�	y�N�(v���ښ:g��>�IA�u�"�j�:�$�x��N}@�� ��t��9uv�o�8��eK뭕#�xH��(���W�&3)�'g�,��_Kv�Т����֬rf[P�Y*?9ԩYI[��� c���l�7�(�'fb�RVbdF�g�oԹls
����A�YO���Z�����YT���e�u�p�� ��Q,��~��Z����,s��(��C�ES՜߿n~f%[q0��sYS��-��n8��7u'�44R䙗b���K)R�n�ݗ�-��,&ժ�s^P��|&JQoA�}i��RoIQ�o�G:��W��L�4��6�_e� ,�[D����3��nԫz���9�vj�{j�W� d���}X���)b8��!���(��I<M�]z$�^�(S����K"�Qv7Ano�ő�G璮8+0��7q��>o��~���.f��L6������!6N�UhI��~�(E�D����E�Z���oQ����zQx_�[Z�ɲB��MU7
<�DP��n�-z|�dB���b6t~����ܳ�s$8G9�Ĩn|�i#Z���!AY�A ��@Z�~̿d j�ى�_�I/���ȠS(D���w�MN���o�W������?�%ۉ�8�С/����~/�;m� ��q�{՚�or�;�L쾉��rI�m�2<麤�L ��aT��HQ[t�ӌ��sN[L\pd��*ٛ$S_J|���ݽ��1�/9�P����������N}Ha!Qe��ȡ+�5� Xݷx���|F��:�FuhJhF��#��
z�"cE�М�
��Ʈ�
n�Fי�aG�{~Dof������3D�b���zYY5�#_X�p/^C/� �ơ��I�*>\x
o���8�4��v�O5~�C��kk�4�7I&���}WV�bAkp������64�a9t��k��#M��Jl�cc�p�t�gP�#������?�XHOP�{�OM�t!6w�ۥ<��� ��=s�D@�"���.�b���xeD ����k��-���9y+�jKO�Z$�#���?���sr!2�e��ȎM�>&K���C�$�0�:'gj
T���+������i($�5���3c��R�0��b�T!�R	eX�hI�9�a�R�c�i�A�܎�Sd4���$���s�%]63
?
zH!@�G�Ģ����%$���T @y*dB9��9�����t
#�*IM��yz��$�JxQ:7|��!~rfU�;�!�Y�Zw��_)��4e��u�ټq�x�4��/Pk8(�/�{�,9�2�i��Í���E��k���"˱ؽ�K���Ng���1b��$8�>WFZ���18Z�!D}�j�ƽ�V׼�.q�������'�)�D�S�Zp���Qh�[+	t.��Kc���-����8��9�8g�� ��-t{/SA-O[@�<�rRZ� �4��o���o���K�@��i�cV"�}�>+���e3�l)�_���o�z�5� f|wb�pp�{��f���(�Xp�%�q�$�JN|o��ຎ<�`G=�t��U B���!����޲Vv�%]؏��A�.+�������j-�C��>���3���'�A�B{�^�^��J%���*KGm�i��7�Y	�z��n��ֹ��r����,�ng�/�����F'��1�R����;���ɏm� 4���$j(g���B�~�y��F,��B�cc���LN�����4$�Ʋ�uSd�9y!r��1��p ��%]N�{�r#EIW�g
�D��3�l�pi0ɔ��7���� ��8~��p^�l+�L���F0ӺǤd��eH�Xqp�_6�X0裗���fQ͚r� �'�Y�"�H�ãq�q ��O�Jy����q_	�b%r���v���Lo��:�"�;��6g�Z���'��+r'�?�"3�!��7��-+E+r���T�R���Λ�4�N�T���K�j3(7��p�X&������5��1^e0HS��ִv���^2vc�!beFM�,5}[�&��E!kИ � �ƑI!��/k:��&�P\��h ��t��1��3�nsz����
���d��d%6��m*���W��~� kܛ�fLNk(Ӑ�o
�2�Vo�C�	�|�d�}e���&ݬ��r��*uo��e�:�7��J�$��Ӆf��,x+���e^�����W��D�ؓT8���+`����$L(���o`��֬6�|���_��4��'��^nx/v���|7I�`���G�(d;]Ҍ��x�r��^6�L$v�V}.�s�4B%{�� �Ō{=�9��-.B�P�@�ͼ��.����d��Y]6[�V�b���Qd����5+���oۺ�e��.׏�iR��.a����/d�xf�6_�N���f*�V��~͊N�b����4s\~��+)��{�"~n֙k����>\�VR_o
����7���*����"k�w��?hi��NI�q��V�uVzi��%J���#q:����Bu�25��rF����t�L�IN�_R��YSP�(��=B����e���a�v�417�E�=�:�!�2u@�8� ��º�J�㤏=c�@�)m��ip �פm2]�ʊ{�a��>W����ƞ�t�����0��A�������e|`��(�LX�f�݆��2&�!an�i���:��>[E"�U�z��Ն�����D���K�e���.�d�*
�V��.�ځHh�䨛?���g|ר�״P
�2tT2�?z�����g�(�>[w�$<�N�7�q}m� �=�;g����H5^d���,�^FbcI���]���0ag9u��[�dp�������4N�vi#!�Ar�=��z��=<F��Z��uA�6�\�W�'Z����7p �>{��y�7�U�`�Җ-�[Z!�!�[���{����9h'F�����I;�\��%��q�^�a�7a��(+��*��<��ԐD&%i�|˴�|�%� �\�F�L�s��# �]L�ؖ����V�%�{�?Ь�����C�Z�&'~�uΕL��1����Kt���Y�'$u.E�k��tZV���OVAƙж������0!/xfϸ�'W�_���}s.�j%��~H�B�ە=كb�O(V�`V���z����D���o����6|�{N�	F��׃.���W��c��ۉ#e�(ͫ����Á%.�a��4��N�եƎ;T>��:��8+�uK��4�p'��ȼ^�r�u^��o
V:ܹ��u��hl�0$�H�P���a�)����q뜌Ĝ[���?	�)���b[��B�R���E�S��0[&@��k;���*��53�S1÷�z��"�����c'fܾƪa���p#Z���J>�5�b�(n�ldd��,I��р�;��mW�X�|�3p;��|A��9K������I	� ߝ�7���akBH�O"��Ϊo���zd�$�ɹ�<�Xf��W�j}@b���'��K&��AW�5q���������"�=ȓ�cD*����(k�i&�(T�n5؂O�Wd1�[P��D�T�a�(�K�l[ӌ��8X9"���H���[�A`�YK�Ś���;ҍ�Bo@1����ҏ�v��^��ͪE�z�";gd����y9���9Q�QS������
���8��o<��~G�o�4J>�����Y�����%��V�[�U[� �G�!V���[�������헷#	���#w��� X^���X�L�}��*"�rKd�_��p�A�bU[X�/2��>�U:�Ŭ�^22���J�:$�l������%���(z�JD�9xH���碔3�1��Z0�?C&�t��Q�m�J�A����!�
�Kj�	#�Wh�d8l�p��t�e�k�w���t%p�/<Hl<K� �   ����7I,?����?�	M�E��yK릲}�Hb�oh{����ק?/i����οO`��A!!Jo�n�k��B��ރ���p���"%r���M�2OL?#?��P�g����A�Z����C��.k�>��o/�8n���(�(��J{�?�N���k�m      �   �   x�=�A�� C��0��.s�sL�2�D���B1e!�n耉4a[���$�����Wpݕp�Y"�y��\K(��8����"��A,��+�J�p}s�q�j���0��b*��!��3��mV�3l�q6y�s�]��x�C`�.���D�f��L��8*x�l7x�\7(��=��ȮN��.��g� Y�]px>?���*bI      �      x������ � �      �   l
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
+��9o���G]ʂ+IԨvdr�`���4n-Z�e�Y����QkG�	��UX�g����޵�*6w�����S��V�?HMT��Y����q�d��      �      x��}Ɏd�����+�M7�[���Л^ע���>܀p���j�[A��]A;e�HI�����P�*��4�6�c4��ŗ�����ϧ������?N�v��8�c�O%�y�<����{5�(���C0N�R��Z-��v�At��,���M|P���ǔ�(}���[�m<m�qܯN��)9
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
��5O޾�~$��_��w^��h���ϴ�w���p��׵�c���~�eSb�\�;����T�Ҭ�Mگij�ؠ<	��~5�^n��.�Ѷw�W�P��V��'����"��"��������=��������g��8݆�ȿ�#��4�\��_ l��?'�)�^W�e�����5�?-�k��`C��_S����)�!�;]b�����OԔw�i�y��ñ��ۦ �R��Z)91!p����������     