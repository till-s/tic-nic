
# Unfortunately, efinix does not fully support scripting.
# At least their interface designer does, however.
# We use it to
#   - generate the project interface xml (xxx.peri.xml)
#     from an isf file which is easier to maintain in git
#     and allows scripting.
#   - generate the constraints for the io-registers
#     and clock definitions, i.e., everything that can
#     be automated. These constraints are saved into
#     <proj>.pt.sdc. Manually created additional constraints
#     should live elsewhere!

# RUN THIS SCRIPT IN THE PROJECT TOP DIRECTORY (where the xml resides)
# AND ENSURE EFX 'setup.sh' HAS BEEN SOURCED.
#
#  python3 this_script.py
import re
import glob
import os
import sys
import pprint
import shutil
from   lxml import etree as ET

# Must be run from the project directory
projmatch = None
for xml in glob.glob( '*.xml' ): 
  m = re.match( '^([^.]*)[.]xml$', xml )
  if not m is None:
    if not projmatch is None:
      raise RuntimeError( "project XML not found; too many <xxx.xml> files in this directory" )
    projmatch = m
if projmatch is None:
  raise RuntimeError("project XML not found; expect to run in the project directory and find one '<proj_name>.xml' file")

# Tell python where to get Interface Designer's API package
pt_home = os.environ['EFXPT_HOME']
sys.path.append(pt_home + "/bin")

from api_service.design import DesignAPI  # Get access to design database API
from api_service.device import DeviceAPI  # Get access to device database API
import api_service.excp.design_excp as APIExcp  # Get access to API exception

is_verbose = True  # Set to True to see detail messages from API engine
design = DesignAPI(is_verbose)
device = DeviceAPI(is_verbose)

# Create empty design
# FIXME - could extract device from project XML
etree = ET.parse( projmatch.group(0) )
device_name = etree.find('.//{http://www.efinixinc.com/enf_proj}device').get('name')
project_name = projmatch.group(1)
output_dir = "."  # New pt_demo periphery design will be generated in this directory
design.create(project_name, device_name, output_dir)

exec( open("{}_io.isf".format(project_name) ).read() )

# Check design, generate constraints and reports
design.generate(enable_bitstream=False)

# Save the configured periphery design
design.save()

# copy constraints out of the 'outflow' directory which seems
# to be cleaned sometimes by efx...
shutil.copy( '{}/outflow/{}.pt.sdc'.format(output_dir, project_name),
             '{}/{}.pt.sdc'.format(output_dir, project_name) )

os.system('./update_git_version_pkg.sh')
