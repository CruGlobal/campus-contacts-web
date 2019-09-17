import React from 'react';

export const appContextDefaultValue = { orgId: '' };

export type AppContextValue = typeof appContextDefaultValue;

export const AppContext = React.createContext(appContextDefaultValue);
