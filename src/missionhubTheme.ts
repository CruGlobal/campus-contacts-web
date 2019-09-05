import styled, { CreateStyled } from '@emotion/styled';

export const missionhubTheme = {
    font: {
        family: 'Source Sans Pro',
        size: '14px',
    },
    colors: {
        primary: '#505256',
        secondary: '#B4B6BA',
        highlight: '#3CC8E6',
        highlightDarker: '#007398',
        white: '#ffffff',
    },
    graph: {
        background: 'transparent',
        fontFamily: 'Source Sans Pro',
        fontSize: 10,
        textColor: '#B4B6BA',
        grid: {
            line: {
                stroke: '#ECEEF2',
                strokeWidth: 1,
            },
        },
        axis: {
            ticks: {
                text: {
                    fontWeight: 600,
                    letterSpacing: '1px',
                },
            },
        },
        legends: {
            text: {
                fontSize: 12,
            },
        },
    },
};

export type MissionHubTheme = typeof missionhubTheme;

export default styled as CreateStyled<MissionHubTheme>;
