from rdflib import URIRef, Graph, Literal, RDFS, OWL, RDF

from excel_exporters.export_helpers import create_iri_for_object_type
from excel_exporters.ontology_constants import IS_PART_OF_IRI, HAS_FUNCTION, HAS_PART_IRI
from owl_handlers.owl_constructors import get_owl_has_value_restriction_to_graph, \
    get_owl_some_values_restriction_to_graph, get_owl_all_values_restriction_to_graph


def add_parts_to_object_type(excel_sheet_name: str, parts_string:str, object_type: URIRef, ontology: Graph, object_type_register: dict):
    part_strings = parts_string.split(',')
    for part_string in part_strings:
        part = __get_mereology(mereology_string=part_string, object_type_register=object_type_register, ontology=ontology)
        some_values_restriction = get_owl_some_values_restriction_to_graph(owl_object_property=IS_PART_OF_IRI,value=part,ontology=ontology)
        ontology.add((object_type, RDFS.subClassOf, some_values_restriction))
        # all_values_restriction = get_owl_all_values_restriction_to_graph(owl_object_property=IS_PART_OF_IRI,value=part, ontology=ontology)
        # ontology.add((object_type, RDFS.subClassOf, all_values_restriction))

def add_wholes_to_object_type(excel_sheet_name: str, wholes_string:str, object_type: URIRef, ontology: Graph, object_type_register: dict):
    whole_strings = wholes_string.split(',')
    for whole_string in whole_strings:
        whole = __get_mereology(mereology_string=whole_string, object_type_register=object_type_register,ontology=ontology)
        some_values_restriction = get_owl_some_values_restriction_to_graph(owl_object_property=HAS_PART_IRI, value=whole, ontology=ontology)
        ontology.add((object_type, RDFS.subClassOf, some_values_restriction))
        # all_values_restriction = get_owl_all_values_restriction_to_graph(owl_object_property=HAS_PART_IRI, value=whole, ontology=ontology)
        # ontology.add((object_type, RDFS.subClassOf, all_values_restriction))


def __get_mereology(mereology_string: str, object_type_register: dict, ontology:Graph)  -> URIRef:
    mereology_string_stripped = mereology_string.strip()
    mereology_label = Literal(mereology_string_stripped, lang='pl')
    if mereology_label in object_type_register.keys():
        mereology = object_type_register[mereology_label]
    else:
        mereology = create_iri_for_object_type(object_type_index=len(object_type_register) + 1)
        ontology.add((mereology, RDF.type, OWL.Class))
        ontology.add((mereology, RDFS.label, mereology_label))
        object_type_register.update({mereology_label: mereology})
    return mereology
