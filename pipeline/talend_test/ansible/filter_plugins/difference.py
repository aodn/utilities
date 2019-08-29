import difflib

def unified_diff(diffs):
    # format before and after strings as unified diff
    unified_deltas = []

    for difference in diffs:
        before = difference['before'].splitlines(True)
        after = difference['after'].splitlines(True)
        unified_diff = difflib.unified_diff(before, after, fromfile=difference['before_header'], tofile=difference['after_header'])
        unified_delta = ''.join(unified_diff)
        unified_deltas.append(unified_delta)
    return unified_deltas

class FilterModule(object):
    '''
    custom jinja2 filters for working with diffs
    '''

    def filters(self):
        return {
            'unified_diff': unified_diff
        }
