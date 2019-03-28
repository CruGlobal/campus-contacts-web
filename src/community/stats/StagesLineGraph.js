import React from 'react';
import { ResponsiveLine } from '@nivo/line';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';

const Container = styled.div`
    width: 75%;
    height: 220px;
    margin-bottom: 30px;
    border-radius: 5px;
    > div {
        background: white;
        border-radius: 0 0 5px 5px;
    }
`;

// The Tabs at top of graph
const TabsLayout = styled.div`
    display: flex;
    flex-direction: column;
    align-item: flex-start;
    background: #3cc8e6;
    width: 99%;
    margin-left: 1px;
    height: 70px;
    font-size: 12px;
    color: white;
    > p {
        margin-left: 10px;
        margin-top: 5px;
        margin-bottom: -10px;
    }
    ::after {
        color: transparent;
        content: '';
        position: absolute;
        top: 234px;
        left: 0;
        right: 33%;
        margin: auto;
        border-bottom: 6px solid white;
        border-left: 6px solid transparent;
        border-right: 6px solid transparent;
        width: 0;
    }
`;

// Didn't know a way to define left and right rounded edges for the tabs on the graph so I have this solution for now
// Tab for left corner
const TabsEdgeL = styled(TabsLayout)`
    border-top-left-radius: 5px;
`;
// Tab for right corner
const TabsEdgeR = styled(TabsLayout)`
    border-top-right-radius: 5px;
`;

const TabsActive = styled(TabsLayout)`
    background: #007398;
`;

// Container holding tabs
const TabsContainer = styled.div`
    display: grid;
    grid-template-columns: repeat(4, 1fr);
`;

const TabsNumber = styled.p`
    font-size: 2rem;
`;

// Takes in objective(the tasks or step), stats(the numbers completed), edge to check if its a edge tab, and then either left or right.
// I setup a conditional statement, if its a edge than check if its the right corner tab, if not than its left corner tab.
// If its not a corner tab than just render a regular tab
// Also added active to change the background color on which tab is selected
const Tabs = ({ objective, stats, edge, edgeR, edgeL, active }) =>
    edge ? (
        edgeR ? (
            <TabsEdgeR>
                <p>{objective}</p>
                <TabsNumber>{stats}</TabsNumber>
            </TabsEdgeR>
        ) : (
            <TabsEdgeL>
                <p>{objective}</p>
                <TabsNumber>{stats}</TabsNumber>
            </TabsEdgeL>
        )
    ) : active ? (
        <TabsActive>
            <p>{objective}</p>
            <TabsNumber>{stats}</TabsNumber>
        </TabsActive>
    ) : (
        <TabsLayout>
            <p>{objective}</p>
            <TabsNumber>{stats}</TabsNumber>
        </TabsLayout>
    );

export const StagesLineGraph = props => (
    <Container>
        <h3>STEPS OF FAITH WITH OTHERS</h3>
        <TabsContainer>
            {/* On click set our graph state equal to Bar */}
            <div onClick={() => props.setGraph(props.graph[0])}>
                <Tabs
                    edge={true}
                    objective={'PEOPLE/STEPS OF FAITH'}
                    stats={'40 / 120'}
                />
            </div>
            {/* On click set our graph state equal to Line */}
            <div onClick={() => props.setGraph(props.graph[1])}>
                <Tabs active={true} objective={'STEPS COMPLETED'} stats={20} />
            </div>
            <Tabs objective={'PEOPLE MOVEMENT'} stats={2} />
            <Tabs edgeR={true} edge={true} />
        </TabsContainer>
        <ResponsiveLine
            data={[
                {
                    id: 'Steps Completed',
                    color: 'hsl(195, 100%, 74%)',
                    data: [
                        {
                            x: '3/19/2019',
                            y: 21,
                        },
                        {
                            x: '3/20/2019',
                            y: 23,
                        },
                        {
                            x: '3/21/2019',
                            y: 24,
                        },
                        {
                            x: '3/22/2019',
                            y: 23,
                        },
                        {
                            x: '2/23/2019',
                            y: 25,
                        },
                        {
                            x: '3/24/2019',
                            y: 26,
                        },
                        {
                            x: '3/25/2019',
                            y: 28,
                        },
                    ],
                },
            ]}
            margin={{
                top: 30,
                right: 40,
                bottom: 50,
                left: 40,
            }}
            xScale={{
                type: 'point',
            }}
            yScale={{
                type: 'linear',
                stacked: true,
                min: 'auto',
                max: 'auto',
            }}
            enableGridX={false}
            enableGridY={false}
            axisTop={null}
            axisRight={null}
            axisBottom={{
                orient: 'bottom',
                tickSize: 10,
                tickPadding: 10,
                tickRotation: 0,
            }}
            axisLeft={null}
            dotSize={15}
            dotColor="white"
            dotBorderWidth={2}
            dotBorderColor="#3CC8E6"
            enableDotLabel={true}
            dotLabel="y"
            dotLabelYOffset={-15}
            animate={true}
            motionStiffness={90}
            motionDamping={15}
            colors={'hsl(195, 100%, 74%)'}
        />
    </Container>
);

StagesLineGraph.propTypes = {
    objective: PropTypes.string,
    stats: PropTypes.number,
};
