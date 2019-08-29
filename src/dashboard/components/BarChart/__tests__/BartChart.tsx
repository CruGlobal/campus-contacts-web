import React from 'react';

import { renderWithContext } from '../../../testUtils';
import BarChart from '../';

describe('<BarChart />', () => {
    it('should render properly', async () => {
        renderWithContext(<BarChart data={[]} />).snapshot();
    });

    it('should render properly with data, key, index by', async () => {
        const graphData = [{ a: 1, b: 2 }, { a: 2, b: 3 }, { a: 3, b: 4 }];

        renderWithContext(
            <BarChart data={graphData} keys={['a']} indexBy={'b'} />,
        ).snapshot();
    });
});
