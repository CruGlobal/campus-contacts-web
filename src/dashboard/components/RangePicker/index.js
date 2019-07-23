import styled from '@emotion/styled';
import React, { useState } from 'react';
import { withTheme } from 'emotion-theming';
import PropTypes from 'prop-types';
import moment from 'moment';
import 'react-dates/initialize';
import 'react-dates/lib/css/_datepicker.css';
import { DateRangePicker } from 'react-dates';

const Container = styled.div`
    display: flex;
    align-items: center;

    .DateRangePicker {
    }

    .DateRangePickerInput {
        display: flex;
    }

    .DateInput {
        width: 108px;
        height: 32px;
        text-align: center;
        display: flex;
        justify-content: center;
        align-items: center;
        background-color: #eceef2;
        text-align: center;
        border-radius: 0 16px 16px 0;
        overflow: hidden;
        cursor: pointer;

        &:first-child {
            border-radius: 16px 0 0 16px;
            margin-right: 1px;
        }

        &:hover {
            background-color: #e2e2e2;
        }

        input[type='text']:focus {
            background-color: #e2e2e2;
        }
    }

    .DateInput_input {
        height: 100%;
        font-size: 14px;
        line-height: 20px;
        padding: 0;
        background-color: transparent;
        border-color: transparent;
        border-radius: 0;
        text-align: center;
        color: ${({ theme }) => theme.colors.primary};
        cursor: pointer;
    }

    .CalendarDay__selected_span {
        background: ${({ theme }) => theme.colors.highlight};
        color: white;
        border: 1px solid #2fb0d8;
    }

    .CalendarDay__selected {
        background: ${({ theme }) => theme.colors.highlightDarker};
        color: white;
        border: 1px solid #2fb0d8;
    }

    .CalendarDay__selected:hover {
        background: ${({ theme }) => theme.colors.highlightDarker};
        color: white;
    }

    .CalendarDay__hovered_span:hover,
    .CalendarDay__hovered_span {
        background: ${({ theme }) => theme.colors.highlight};
        border: 1px solid #2fb0d8;
        color: white;
    }

    .DateRangePickerInput_arrow {
        display: none;
    }

    .DateInput_fang {
        top: 56px;
    }
`;

const CalendarIcon = styled.div`
    background-image: url(/src/dashboard/assets/icons/calendar.svg);
    width: 24px;
    height: 24px;
    margin-right: 12px;
`;

const RangePicker = ({ onDatesChange, startDate, endDate }) => {
    const [dates, setDates] = useState({ startDate, endDate });
    const [focus, setFocus] = useState();

    const datesChanged = ({ startDate, endDate }) => {
        setDates({ startDate, endDate });
        onDatesChange({ startDate, endDate });
    };

    return (
        <Container>
            <CalendarIcon />
            <DateRangePicker
                startDate={dates.startDate}
                startDateId="startDateId"
                endDate={dates.endDate}
                endDateId="endDateId"
                onDatesChange={datesChanged}
                focusedInput={focus}
                onFocusChange={focusedInput => {
                    setFocus(focusedInput);
                }}
                readOnly={true}
                noBorder={true}
                customArrowIcon={null}
                isOutsideRange={day => day.isAfter(moment.now())}
            />
        </Container>
    );
};

export default withTheme(RangePicker);

RangePicker.propTypes = {
    onDatesChange: PropTypes.func,
    startDate: PropTypes.object,
    endDate: PropTypes.object,
};
