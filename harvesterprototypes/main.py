from harvester import GenericCsvHarvester
import json


def main(opinionated):
    fn = 'opinionated' if opinionated else 'unopinionated'
    with open('example_config/{}.json'.format(fn)) as file:
        pipeline_config = json.load(file)
    harvest = GenericCsvHarvester(config=pipeline_config)
    if opinionated:
        print("using the opinionated approach...\n")
        harvest.opinionated_harvester()
    else:
        print("using the unopinionated approach...\n")
        harvest.unopinionated_harvester()


if __name__ == "__main__":
    # opinionated
    main(True)
    # unopinionated
    main(False)
