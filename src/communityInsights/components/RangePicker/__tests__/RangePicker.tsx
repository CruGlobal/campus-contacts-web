import React from 'react';
import moment from 'moment';

import { renderWithContext } from '../../../../testUtils';
import RangePicker from '..';

describe('<RangePicker />', () => {
    it('should render properly', async () => {
        const endDate = moment('2019-07-22');
        const startDate = moment('2019-07-15');
        renderWithContext(
            <RangePicker
                startDate={startDate}
                endDate={endDate}
                onDatesChange={dates => {}}
            />,
        ).snapshot();
    });
});
