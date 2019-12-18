import React from 'react';

import { renderWithContext } from '../../../../testUtils';

import BarChart from '..';

describe('<BarChart />', () => {
    it('should render properly', async () => {
        renderWithContext(
            <BarChart
                nullContent={'stepsOfFaithCompleted'}
                data={[]}
                keys={['a']}
                indexBy={'b'}
                filterType={'month'}
                onFilterChanged={() => {}}
                index={0}
            />,
        ).snapshot();
    });

    it('should render properly with data, key, index by', async () => {
        const graphData = [{ a: 1, b: 2 }, { a: 2, b: 3 }, { a: 3, b: 4 }];

        renderWithContext(
            <BarChart
                nullContent={'stepsOfFaithCompleted'}
                data={graphData}
                keys={['a']}
                indexBy={'b'}
                filterType={'month'}
                onFilterChanged={() => {}}
                index={0}
            />,
        ).snapshot();
    });
});
