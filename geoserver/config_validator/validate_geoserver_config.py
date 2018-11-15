import argparse
import os
from xml.etree import ElementTree


# TODO: validate styles?
# TODO: other layer validation functions?

#
# VALIDATION FUNCTIONS
#

class ValidationError(Exception):
    pass


def validate_layer_default_style(layer, styles):
    """Validator to check for a valid defaultStyle tag

    :param layer: layer to validate
    :param styles: list of *valid* styles
    :return: None
    """
    if layer.style in styles:
        # style is valid
        return

    if layer.style.id is None:
        status_message = "missing defaultStyle tag".format(layer=layer)
    else:
        status_message = "references nonexistent style: {layer.style.id}".format(layer=layer)
    raise ValidationError(status_message)


# validator function references added to this list will be included in overall validation of each layer object
ALL_LAYER_VALIDATORS = [
    validate_layer_default_style
]


#
# CONFIGURATION OBJECTS
#

class Layer(object):
    """Represents a layer.xml file in a Geoserver config workspace
    """

    def __init__(self, name, style, xml_file_path):
        self.name = name
        self.style = style
        self.xml_file_path = xml_file_path

        self.status = 'UNKNOWN'
        self.status_message = ''

    def __repr__(self):
        return ("{s.__class__.__name__}(name='{s.name}', style={s.style}, "
                "invalid_message={s.invalid_message}, xml_file_path='{s.xml_file_path}')").format(s=self)

    def __str__(self):
        return "{s.name}: status='{s.status}' reason='{s.status_message}'".format(s=self)

    @classmethod
    def from_xml_file(cls, xml_file):
        """Construct from XML file path

        :param xml_file: path to layer.xml
        :return: new instance
        """
        root = ElementTree.parse(xml_file)
        style = Style(root.findtext('./defaultStyle/id'), root.findtext('./defaultStyle/name'))
        return cls(root.findtext('./name'), style, xml_file)


class Style(object):
    """Represents a style XML file in a Geoserver config directory
    """

    def __init__(self, id_, name):
        self.id = id_
        self.name = name

    def __eq__(self, other):
        return self.id == other.id

    def __hash__(self):
        return hash(self.id)

    def __repr__(self):
        return "{s.__class__.__name__}(id={id}, name={name})".format(s=self,
                                                                     id=quote_string_if_not_none(self.id),
                                                                     name=quote_string_if_not_none(self.name))

    @classmethod
    def from_xml_file(cls, xml_file):
        """Construct from XML file path

        :param xml_file: path to style XML file
        :return: new instance
        """
        root = ElementTree.parse(xml_file)
        return cls(root.findtext('./id'), root.findtext('./name'))


#
# UTILITY FUNCTIONS
#

def quote_string_if_not_none(string_, quote="'"):
    """Return a quoted string, or None.

    :param string_: input string
    :param quote: quote character
    :return: quoted string, or bare None
    """
    return string_ if string_ is None else "{quote}{string}{quote}".format(string=string_, quote=quote)


def find_layer_xml_files(workspace_dir):
    """Recursively find all layer.xml files in a directory

    :param workspace_dir: directory to walk
    :return: list of paths layer.xml files
    """
    layer_xml_files = []
    for root, dirs, files in os.walk(workspace_dir):
        layer_xml_files.extend(os.path.join(root, name) for name in files if name == 'layer.xml')
    return layer_xml_files


def find_style_xml_files(root_dir):
    """Recursively find all style XML files, by including all XMl files inside a directory named 'styles'

    :param root_dir: directory to walk
    :return: list of paths to style XML files
    """
    style_xml_files = []
    for root, dirs, files in os.walk(root_dir):
        if os.path.basename(root) == 'styles':
            style_xml_files.extend(os.path.join(root, name) for name in files if name.endswith('.xml'))
    return style_xml_files


def load_layers(workspace_dir):
    """Load all layer.xml into a set of Layer objects

    :param workspace_dir: directory to walk
    :return: set containing a Layer instance for each layer.xml file found
    """
    layer_xml_files = find_layer_xml_files(workspace_dir)
    return {Layer.from_xml_file(layer_xml) for layer_xml in layer_xml_files}


def load_styles(root_dir):
    """Load all styles into a set of Style objects

    :param root_dir: directory to walk
    :return: set containing a Style object for each XML file found
    """
    xml_files = find_style_xml_files(root_dir)
    return {Style.from_xml_file(x) for x in xml_files}


def validate_layer(layer, styles):
    """Validate a Layer instance

    :param layer: Layer instance to validate
    :param styles: collection of all valid styles
    :return: None
    """
    for validate in ALL_LAYER_VALIDATORS:
        validate(layer, styles)


def validate_layers(layers, styles):
    """Validate a sequence of layers

    :param layers: sequence of layers to validate
    :param styles: sequence of valid styles
    :return: tuple containing two lists, with the first being valid layers and the second being invalid layers
    """
    valid_layers = []
    invalid_layers = []

    for layer in layers:
        try:
            validate_layer(layer, styles)
        except ValidationError as e:
            layer.status = 'INVALID'
            layer.status_message = str(e)
            invalid_layers.append(layer)
        else:
            layer.status = 'VALID'
            valid_layers.append(layer)

    return valid_layers, invalid_layers


def get_layer_summary(valid_layers, invalid_layers):
    """Get a summary report on invalid layers, showing counts and printing details of invalid layers

    :param valid_layers: list of valid layers
    :param invalid_layers: list of invalid layers
    :return: string containing report text
    """
    lines = [
        "VALID LAYERS COUNT: {}".format(len(valid_layers)),
        "INVALID LAYERS COUNT: {}".format(len(invalid_layers)),
        'INVALID LAYERS:'
    ]
    lines.extend((str(l) for l in invalid_layers))
    return os.linesep.join(lines)


#
# COMMAND-LINE INTERFACE
#

def argparse_type_existing_dir(dir_):
    if os.path.isdir(dir_):
        return dir_
    raise argparse.ArgumentTypeError("invalid geoserver-config directory '{dir}'".format(dir=dir_))


def cli():
    """Command line entry point

    :return: None
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('geoserver_config_dir',
                        metavar='geoserver-config-dir',
                        type=argparse_type_existing_dir,
                        help='Path to a geoserver-config directory')
    args = parser.parse_args()

    all_layers = load_layers(os.path.join(args.geoserver_config_dir, 'workspaces'))
    all_styles = load_styles(args.geoserver_config_dir)

    valid_layers, invalid_layers = validate_layers(all_layers, all_styles)
    print(get_layer_summary(valid_layers, invalid_layers))


if __name__ == '__main__':
    cli()
