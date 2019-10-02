import React from 'react';

import { renderWithContext } from '../../../../testUtils';

import NullState from '..';

describe('<NullState /> for non ImpactInfo component', () => {
    it('Should render properly', () => {
        const content = 'personalStepsCompleted';
        const { snapshot, unmount } = renderWithContext(
            <NullState content={content} />,
        );
        snapshot();
        unmount();
    });
});
