import React from 'react';

import { renderWithContext } from '../../../../testUtils';

import NullState from '..';

describe('<NullState /> for non ImpactInfo component', () => {
    it('Should render properly', () => {
        const width = 400;
        const { snapshot, unmount } = renderWithContext(
            <NullState width={width} />,
        );
        snapshot();
        unmount();
    });
});
