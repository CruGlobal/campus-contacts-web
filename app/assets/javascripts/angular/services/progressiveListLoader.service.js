angular
    .module('missionhubApp')
    .factory('ProgressiveListLoader', progressiveListLoader);

function progressiveListLoader(httpProxy, modelsService, _) {
    const pageSize = 25;
    const overlapMargin = 1;

    function ProgressiveListLoader(options) {
        const modelType = options.modelType;
        const requestDeduper = options.requestDeduper;
        const errorMessage = options.errorMessage;
        let list = [];

        this.loadMore = function(params = {}) {
            // There are two situations where our length gets out of sync from our offset:
            // 1. The already-loaded portion of the data set becomes larger on the server. In this
            // case, we would be requesting the next set after #10, but what we think is #10 is
            // really 11th, so we would see #10 again in the response. This duplication is covered
            // by union-ing the response data with the existing loaded records.
            // 2. The already-loaded portion of the data set becomes smaller on the server. In this
            // case, we would be requesting the next set after #10, but what we think is #10 is
            // now 9th, so we would never load #11 as the server picks up with the 11th item (#12).
            // This off-by-one issue is covered by loading one extra row every 'page' and throwing
            // away duplicates. `overlapMargin` defines how many extra rows to load.
            const page = {
                limit: pageSize + overlapMargin,
                offset: Math.max(list.length - overlapMargin, 0),
            };
            params['page[limit]'] = page.limit;
            params['page[offset]'] = page.offset;

            return httpProxy
                .get(
                    modelsService.getModelMetadata(modelType).url.all,
                    params,
                    {
                        deduper: requestDeduper,
                        errorMessage:
                            errorMessage ||
                            'error.messages.progressive_list_loader.load_chunk',
                    },
                )
                .then(function(resp) {
                    list = _.unionBy(list, resp.data, 'id');
                    const loadedAll = resp.meta.total <= list.length;

                    return {
                        nextBatch: resp.data,
                        list: list,
                        loadedAll: loadedAll,
                        total: resp.meta.total,
                    };
                });
        };

        this.reset = function(newList) {
            list = newList || [];
            return this;
        };
    }

    return ProgressiveListLoader;
}
