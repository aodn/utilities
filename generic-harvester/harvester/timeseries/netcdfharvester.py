from ..baseharvester import BaseHarvester


class NetcdfHarvester(BaseHarvester):
    
    def __init__(self, config, logger):
        super(NetcdfHarvester, self).__init__(config, logger)

        
    def delete_harvested_data(self, 