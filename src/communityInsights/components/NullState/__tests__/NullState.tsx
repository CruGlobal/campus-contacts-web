import React from 'react';
import NullState from '..';
import { renderWithContext } from '../../../../testUtils';

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

describe('<NullState /> for ImpactInfo', () => {
    it('Should render correct text', () => {
        const { snapshot, unmount } = renderWithContext(
            <NullState impactInfo={true} />,
        );
        snapshot();
        unmount();
    });
});
