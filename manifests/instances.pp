# Create all virtual hosts from hiera
class bioportal::instances (
    $instances,
)
{
  create_resources('apache::vhost', $instances)
}
