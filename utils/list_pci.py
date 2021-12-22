from __future__ import print_function
from xml.dom import minidom
import subprocess


class NodeDevice(object):

    def __init__(self, xmldoc):
        self._xmldoc = xmldoc

    def XMLDesc(self, flags=0):
        return self._xmldoc


class VirshClient(object):

    def listDevices(self, cap):
        popen = subprocess.Popen(['virsh', 'nodedev-list', cap],
                                 stdout=subprocess.PIPE)
        for dev in popen.stdout.readlines():
            dev = dev.strip()
            if not dev:
                continue
            yield dev

    def nodeDeviceLookupByName(self, dev):
        popen = subprocess.Popen(['virsh', 'nodedev-dumpxml', dev],
                                 stdout=subprocess.PIPE)
        lines = popen.stdout.readlines()
        return NodeDevice(''.join(lines))


def get_vendor(pci_dom):
    vendor = pci_dom.getElementsByTagName('vendor')
    if not vendor:
        return {}
    vendor_id = vendor[0].getAttribute('id')
    return {
        "vendor_id": '%04x' % int(vendor_id, 16)
    }


def get_product(pci_dom):
    product = pci_dom.getElementsByTagName('product')
    if not product:
        return {}
    vendor_id = product[0].getAttribute('id')
    return {
        "product_id": '%04x' % int(vendor_id, 16)
    }


def get_data_by_tag(ele, tag):
    eles = ele.getElementsByTagName(tag)
    if not eles:
        return None
    return eles[0].firstChild.data if eles[0].firstChild else None


def get_pci_list():
    try:
        import libvirt                                       # noqa
        driver = libvirt.open('qemu:///system')              # noqa
    except ImportError:
        driver = VirshClient()

    pci_list = []
    for dev in driver.listDevices('pci'):
        pci = {}
        xml = driver.nodeDeviceLookupByName(dev).XMLDesc(0)
        pci_dom = minidom.parseString(xml).firstChild
        for n in pci_dom.getElementsByTagName('name'):
            if n.parentNode.tagName == pci_dom.tagName:
                pci.update(name=n.firstChild.data)
        for cap in pci_dom.getElementsByTagName('capability'):
            if cap.parentNode.tagName == pci_dom.tagName:
                vendor = get_vendor(cap)
                product = get_product(cap)
                domain = int(get_data_by_tag(cap, 'domain'))
                bus = int(get_data_by_tag(cap, 'bus'))
                slot = int(get_data_by_tag(cap, 'slot'))
                func = int(get_data_by_tag(cap, 'function'))
                description = get_data_by_tag(cap, 'product')
                pci.update(
                    vendor_id=vendor.get('vendor_id'),
                    product_id=product.get('product_id'),
                    description=description,
                    address="%04x:%02x:%02x.%1x" % (domain, bus, slot, func),
                )
                capability = cap.getElementsByTagName('capability')
                if capability:
                    cap_type = capability[0].getAttribute('type')
                    pci.update(cap_type=cap_type)
                break
        if pci:
            pci_list.append(pci)


def main():
    line_format = '{} {} {} {:15} {} {}'
    print(line_format.format('VenderId', 'ProductId', 'Address',
                             'CapabilityType', 'PciName',
                             'description',
                             'NumaNode'))

    for pci in get_pci_list():
        print(line_format.format(
            pci['vendor_id'], pci['product_id'], pci['address'],
            pci.get('cap_type', ''),
            pci.get('name', ''),
            pci.get('description', ''),
            pci.get('numa_node', ''),
        ))


if __name__ == '__main__':
    main()
