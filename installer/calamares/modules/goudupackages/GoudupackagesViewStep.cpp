#include "GoudupackagesViewStep.h"

CALAMARES_PLUGIN_FACTORY_DEFINITION( GoudupackagesViewStepFactory,
                                     registerPlugin< GoudupackagesViewStep >(); )

GoudupackagesViewStep::GoudupackagesViewStep( QObject* parent )
    : Calamares::QmlViewStep( parent )
{
}

GoudupackagesViewStep::~GoudupackagesViewStep() = default;

QString
GoudupackagesViewStep::prettyName() const
{
    return tr( "Goudunix packages" );
}
