// Minimal QmlViewStep subclass. All UI lives in goudupackages.qml.

#ifndef GOUDUPACKAGES_VIEWSTEP_H
#define GOUDUPACKAGES_VIEWSTEP_H

#include "DllMacro.h"
#include "utils/PluginFactory.h"
#include "viewpages/QmlViewStep.h"

class PLUGINDLLEXPORT GoudupackagesViewStep : public Calamares::QmlViewStep
{
    Q_OBJECT
public:
    explicit GoudupackagesViewStep( QObject* parent = nullptr );
    ~GoudupackagesViewStep() override;

    QString prettyName() const override;
};

CALAMARES_PLUGIN_FACTORY_DECLARATION( GoudupackagesViewStepFactory )

#endif
