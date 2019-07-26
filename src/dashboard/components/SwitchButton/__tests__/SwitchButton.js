import React from 'react';

import { renderWithContext } from '../../../testUtils';
import SwitchButton from '../';

describe('<SwitchButton />', () => {
    it('should render properly', async () => {
        renderWithContext(<SwitchButton />).snapshot();
    });
});
