import React from 'react';

import { renderWithContext } from '../../../testUtils';
import RangePicker from '../';

describe('<RangePicker />', () => {
    it('should render properly', async () => {
        renderWithContext(<RangePicker />).snapshot();
    });
});
