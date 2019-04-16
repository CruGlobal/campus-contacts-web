import React from 'react';
import styled from '@emotion/styled';
import { css } from '@emotion/core';
import PropTypes from 'prop-types';

const FilterOption = ({ title, filter, onFilterClick, active }) => {
    const activeCss = css`
        color: #007397;
    `;

    const Filter = styled.p`
        ${active ? activeCss : null}
    `;

    const onClick = () => {
        onFilterClick(filter);
    };

    return (
        <Filter
            title={`${filter.startDate} - ${filter.endDate}`}
            onClick={onClick}
        >
            {title}
        </Filter>
    );
};

export default FilterOption;

FilterOption.propTypes = {
    title: PropTypes.string,
    filter: PropTypes.object,
    active: PropTypes.bool,
    onFilterClick: PropTypes.func,
};
