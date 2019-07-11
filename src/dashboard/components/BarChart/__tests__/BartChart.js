import React from 'react';

import { renderWithContext } from '../../../testUtils';
import BartChart from '../';

describe('<BartChart />', () => {
    it('should render properly', async () => {
        renderWithContext(<BartChart />).snapshot();
    });

    it('should render properly with data, key, index by', async () => {
        const graphData = [{ a: 1, b: 2 }, { a: 2, b: 3 }, { a: 3, b: 4 }];

        renderWithContext(
            <BartChart data={graphData} keys={['a']} indexBy={'b'} />,
        ).snapshot();
    });
});
