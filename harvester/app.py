import json
import os
from files import PipelineFile, PipelineFileCollection
from harvester import GenericCsvHarvester
from config import config

from flask import Flask, request


def get_file_names(file):
    return file.local_path


def create_file_collection(path):
    pipeline_collection = PipelineFileCollection()
    for file in os.scandir(path):
        pipeline_collection.append(PipelineFile(local_path=file.path))
    return pipeline_collection


app = Flask(__name__)


@app.route('/')
def run_pipeline():
    ingest_type = request.args.get('ingest', 'replace')
    conf = config
    if ingest_type:
        if ingest_type not in ['replace', 'truncate', 'append']:
            return json.dumps({'status': 'errors', 'details': 'ingest_type must be one of replace, truncate or append'})
        conf['harvest_params']['ingest_type'] = ingest_type
    pipeline_files = create_file_collection('data')
    harvest_runner = GenericCsvHarvester(None, conf['harvest_params'], None, conf['additional'], None)
    result = harvest_runner.run(pipeline_files)
    return json.dumps(result)
