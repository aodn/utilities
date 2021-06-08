import abc
import os
from collections import MutableSet
from setutils import IndexedSet


class PipelineFile(object):
    def __init__(self, local_path):
        self.local_path = local_path


class PipelineFileCollectionBase(MutableSet, metaclass=abc.ABCMeta):
    def __init__(self, data=None):
        super().__init__()

        self._s = IndexedSet()

        if data is not None:
            for f in data:
                self.add(f)

    def __bool__(self):
        return bool(self._s)

    def __contains__(self, v):
        return v in self._s

    def __iter__(self):
        return iter(self._s)

    def __len__(self):
        return len(self._s)

    def __repr__(self):  # pragma: no cover
        return "{name}({repr})".format(name=self.__class__.__name__, repr=repr(list(self._s)))

    def add(self, pipeline_file):
        self._s.add(pipeline_file)
        return True

    # alias append to the add method
    append = add


class PipelineFileCollection(PipelineFileCollectionBase):
    def discard(self, value):
        pass

    def add(self, pipeline_file):
        return self.add(pipeline_file)

