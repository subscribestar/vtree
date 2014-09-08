NodeWrapper = modula.require('vtree/node_wrapper')
Node = class
  $el: $('')
  el: ''

describe 'NodeWrapper', ->

  $render = (name) ->
    $(window.__html__["spec/fixtures/#{name}.html"])

  before ->
    sinon.spy(NodeWrapper::_hooks(), 'init')
    sinon.spy(NodeWrapper::_hooks(), 'unload')

  after ->
    NodeWrapper::_hooks().init.restore()
    NodeWrapper::_hooks().unload.restore()

  describe 'Basic methods', ->
    beforeEach ->
      @$el = $('<div />')
      @node = new Node(@$el)
      @nodeWrapper = new NodeWrapper(@node)

    describe '.constructor', ->

      it 'saves reference to provided view node in @node', ->
        expect(@nodeWrapper.node).to.be.equal @node

      it 'saves reference to node.$el in @$el', ->
        expect(@nodeWrapper.$el).to.be.equal @node.$el

      it 'saves reference to node.el in @el', ->
        expect(@nodeWrapper.el).to.be.equal @node.el

      it 'identifies view', ->
        sinon.spy(NodeWrapper::, 'identifyNodeAttributes')
        node = new Node(@$el)
        nodeWrapper = new NodeWrapper(node)
        expect(nodeWrapper.identifyNodeAttributes).to.be.calledOnce

      it 'initializes new Vtree node', ->
        sinon.spy(NodeWrapper::, 'initNodeDataObject')
        node = new Node(@$el)
        nodeWrapper = new NodeWrapper(node)
        expect(nodeWrapper.initNodeDataObject).to.be.calledOnce

    describe '.initNodeDataObject', ->
      it 'calls Hooks init hooks', ->
        initialCallCount = @nodeWrapper._hooks().init.callCount
        @nodeWrapper.initNodeDataObject()
        expect(@nodeWrapper._hooks().init.callCount).to.be.eql(initialCallCount + 1)

      it 'provides nodeData object to init call', ->
        object = @nodeWrapper._hooks().init.lastCall.args[0]
        expect(object.constructor).to.match(/NodeData/)

    describe '.unload', ->
      it 'calls Hooks unload hooks', ->
        initialCallCount = @nodeWrapper._hooks().unload.callCount
        @nodeWrapper.unload()
        expect(@nodeWrapper._hooks().unload.callCount).to.be.eql(initialCallCount + 1)

      it 'provides nodeData object to init call', ->
        @nodeWrapper.unload()
        object = @nodeWrapper._hooks().unload.lastCall.args[0]
        expect(object.constructor).to.match(/NodeData/)

      it 'deletes reference to nodeData object', ->
        @nodeWrapper.unload()
        expect(@nodeWrapper.nodeData).to.be.undefined

      it 'deletes reference to node object', ->
        @nodeWrapper.unload()
        expect(@nodeWrapper.node).to.be.undefined

  describe 'View initialization', ->

    prepareFixtureData = ->
      TreeManager = modula.require('vtree/tree_manager')
      $els = $render('nodes_with_data_view')
      $newEls = $render('nodes_for_refresh')

      $('body').empty().append($els)
      $('#component1').append($newEls)

      treeManager = new TreeManager
      treeManager.setInitialNodes()
      treeManager.setParentsForInitialNodes()
      treeManager.setChildrenForInitialNodes()

      componentNodeId = $('#component1').data('vtree-node-id')
      @componentNode = treeManager.nodesCache.getById(componentNodeId)
      @componentNode.activate()

      # order matters here
      for view in 'view1 view2 view3 view4 view5 view6 view7 component2 view8 view9'.split(' ')
        id = $('#' + view).data('vtree-node-id')
        @["#{view}Node"] = treeManager.nodesCache.getById(id)
        @["#{view}Node"].activate()

    beforeEach ->
      prepareFixtureData.apply(@)

    describe '.isComponentIndex', ->
      it 'checks if node should initialize a component index node', ->
        expect(@componentNode.nodeWrapper.isComponentIndex()).to.be.true
        expect(@view1Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view2Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view3Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view4Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view5Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view6Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view7Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@component2Node.nodeWrapper.isComponentIndex()).to.be.true
        expect(@view8Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view9Node.nodeWrapper.isComponentIndex()).to.be.false

    describe '.isStandAlone', ->
      it 'checks if node is a stand alone node and not a part of a component', ->
        expect(@componentNode.nodeWrapper.isStandAlone()).to.be.false
        expect(@view1Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view2Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view3Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view4Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view5Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view6Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view7Node.nodeWrapper.isStandAlone()).to.be.true
        expect(@component2Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view8Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view9Node.nodeWrapper.isStandAlone()).to.be.true

    describe '.identifyNodeAttributes', ->
      it 'identifies current node component name', ->
        expect(@componentNode.nodeWrapper.componentName).to.be.eql 'test_component'
        expect(@view1Node.nodeWrapper.componentName).to.be.eql 'test_component'
        expect(@view2Node.nodeWrapper.componentName).to.be.eql 'test_component'
        expect(@view3Node.nodeWrapper.componentName).to.be.eql 'test_component'
        expect(@view4Node.nodeWrapper.componentName).to.be.eql 'test_component'
        expect(@view5Node.nodeWrapper.componentName).to.be.eql 'test_component'
        expect(@view6Node.nodeWrapper.componentName).to.be.eql 'test_component'
        expect(@view7Node.nodeWrapper.componentName).to.be.eql 'test_component'
        expect(@component2Node.nodeWrapper.componentName).to.be.eql 'test_component2'
        expect(@view8Node.nodeWrapper.componentName).to.be.eql 'test_component2'
        expect(@view9Node.nodeWrapper.componentName).to.be.eql 'test_component2'

      it 'identifies current node layout id', ->
        app1LayoutId = @componentNode.nodeWrapper.layoutId
        expect(@componentNode.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view1Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view2Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view3Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view4Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view5Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view6Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view7Node.nodeWrapper.layoutId).to.be.eql app1LayoutId

        app2LayoutId = @component2Node.nodeWrapper.layoutId
        expect(@component2Node.nodeWrapper.layoutId).to.be.eql app2LayoutId
        expect(@view8Node.nodeWrapper.layoutId).to.be.eql app2LayoutId
        expect(@view9Node.nodeWrapper.layoutId).to.be.eql app2LayoutId

      it 'identifies current node namespace name', ->
        expect(@componentNode.nodeWrapper.namespaceName).to.be.eql 'test_component'
        expect(@view1Node.nodeWrapper.namespaceName).to.be.eql 'test_component'
        expect(@view2Node.nodeWrapper.namespaceName).to.be.eql 'test_component'
        expect(@view3Node.nodeWrapper.namespaceName).to.be.eql 'test_component'
        expect(@view4Node.nodeWrapper.namespaceName).to.be.eql 'test_component'
        expect(@view5Node.nodeWrapper.namespaceName).to.be.eql 'test_component'
        expect(@view6Node.nodeWrapper.namespaceName).to.be.eql 'test_component'
        expect(@view7Node.nodeWrapper.namespaceName).to.be.eql 'test_namespace'
        expect(@component2Node.nodeWrapper.namespaceName).to.be.eql 'test_component2'
        expect(@view8Node.nodeWrapper.namespaceName).to.be.eql 'test_component2'
        expect(@view9Node.nodeWrapper.namespaceName).to.be.eql 'test_namespace'

      it 'identifies current node view name', ->
        expect(@componentNode.nodeWrapper.nodeName).to.be.eql 'layout'
        expect(@view1Node.nodeWrapper.nodeName).to.be.eql 'test_view1'
        expect(@view2Node.nodeWrapper.nodeName).to.be.eql 'test_view2'
        expect(@view3Node.nodeWrapper.nodeName).to.be.eql 'test_view3'
        expect(@view4Node.nodeWrapper.nodeName).to.be.eql 'test_view4'
        expect(@view5Node.nodeWrapper.nodeName).to.be.eql 'test_view5'
        expect(@view6Node.nodeWrapper.nodeName).to.be.eql 'test_view6'
        expect(@view7Node.nodeWrapper.nodeName).to.be.eql 'test_view7'
        expect(@component2Node.nodeWrapper.nodeName).to.be.eql 'layout'
        expect(@view8Node.nodeWrapper.nodeName).to.be.eql 'test_view8'
        expect(@view9Node.nodeWrapper.nodeName).to.be.eql 'test_view9'

    describe '.isComponentIndex', ->
      it 'checks if node should initialize a component index node', ->
        expect(@componentNode.nodeWrapper.isComponentIndex()).to.be.true
        expect(@view1Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view2Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view3Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view4Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view5Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view6Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view7Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@component2Node.nodeWrapper.isComponentIndex()).to.be.true
        expect(@view8Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view9Node.nodeWrapper.isComponentIndex()).to.be.false

    describe '.applicationNode', ->
      context 'node is an application', ->
        it 'returns null', ->
          expect(@componentNode.nodeWrapper.applicationNode()).to.be.null
          expect(@component2Node.nodeWrapper.applicationNode()).to.be.null

      context 'node is a component part', ->
        it 'returns null', ->
          expect(@view7Node.nodeWrapper.applicationNode()).to.be.null
          expect(@view9Node.nodeWrapper.applicationNode()).to.be.null

      context 'node is a part of application', ->
        it "provides reference to node's application node", ->
          expect(@view1Node.nodeWrapper.applicationNode()).to.be.equal @componentNode
          expect(@view2Node.nodeWrapper.applicationNode()).to.be.equal @componentNode
          expect(@view3Node.nodeWrapper.applicationNode()).to.be.equal @componentNode
          expect(@view4Node.nodeWrapper.applicationNode()).to.be.equal @componentNode
          expect(@view5Node.nodeWrapper.applicationNode()).to.be.equal @componentNode
          expect(@view6Node.nodeWrapper.applicationNode()).to.be.equal @componentNode
          expect(@view8Node.nodeWrapper.applicationNode()).to.be.equal @component2Node

    describe '.isStandAlone', ->
      it 'checks if node is stand alone and not a part of a component', ->
        expect(@componentNode.nodeWrapper.isStandAlone()).to.be.false
        expect(@view1Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view2Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view3Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view4Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view5Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view6Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view7Node.nodeWrapper.isStandAlone()).to.be.true
        expect(@component2Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view8Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view9Node.nodeWrapper.isStandAlone()).to.be.true

    describe '.initNodeData', ->
      beforeEach ->
        @app1LayoutId = @componentNode.nodeWrapper.layoutId
        @app2LayoutId = @component2Node.nodeWrapper.layoutId

        @componentNodeData = @componentNode.nodeWrapper.nodeData
        @view1NodeData = @view1Node.nodeWrapper.nodeData
        @view2NodeData = @view2Node.nodeWrapper.nodeData
        @view3NodeData = @view3Node.nodeWrapper.nodeData
        @view4NodeData = @view4Node.nodeWrapper.nodeData
        @view5NodeData = @view5Node.nodeWrapper.nodeData
        @view6NodeData = @view6Node.nodeWrapper.nodeData
        @view7NodeData = @view7Node.nodeWrapper.nodeData
        @component2NodeData = @component2Node.nodeWrapper.nodeData
        @view8NodeData = @view8Node.nodeWrapper.nodeData
        @view9NodeData = @view9Node.nodeWrapper.nodeData

      it 'returns NodeData object based on current state of NodeWrapper', ->
        object = @nodeWrapper.initNodeData()
        expect(object.constructor).to.match(/NodeData/)

      it 'sets correct data to all NodeData objects', ->
        expect(@componentNodeData).to.have.property('el', @componentNode.el)
        expect(@componentNodeData).to.have.property('$el', @componentNode.$el)
        expect(@componentNodeData).to.have.property('isComponentIndex', true)
        expect(@componentNodeData).to.have.property('isComponentPart', true)
        expect(@componentNodeData).to.have.property('isStandAlone', false)
        expect(@componentNodeData).to.have.property('componentId', @app1LayoutId)
        expect(@componentNodeData).to.have.property('applicationNode', null)
        expect(@componentNodeData).to.have.property('nodeName', 'Layout')
        expect(@componentNodeData).to.have.property('nodeNameUnderscored', 'layout')
        expect(@componentNodeData).to.have.property('applicationName', 'TestComponent')
        expect(@componentNodeData).to.have.property('applicationNameUnderscored', 'test_component')
        expect(@componentNodeData).to.have.property('namespaceName', null)
        expect(@componentNodeData).to.have.property('namespaceNameUnderscored', null)

        expect(@view1NodeData).to.have.property('el', @view1Node.el)
        expect(@view1NodeData).to.have.property('$el', @view1Node.$el)
        expect(@view1NodeData).to.have.property('isComponentIndex', false)
        expect(@view1NodeData).to.have.property('isComponentPart', true)
        expect(@view1NodeData).to.have.property('isStandAlone', false)
        expect(@view1NodeData).to.have.property('componentId', @app1LayoutId)
        expect(@view1NodeData).to.have.property('applicationNode', @componentNodeData)
        expect(@view1NodeData).to.have.property('nodeName', 'TestView1')
        expect(@view1NodeData).to.have.property('nodeNameUnderscored', 'test_view1')
        expect(@view1NodeData).to.have.property('applicationName', 'TestComponent')
        expect(@view1NodeData).to.have.property('applicationNameUnderscored', 'test_component')
        expect(@view1NodeData).to.have.property('namespaceName', null)
        expect(@view1NodeData).to.have.property('namespaceNameUnderscored', null)

        expect(@view2NodeData).to.have.property('el', @view2Node.el)
        expect(@view2NodeData).to.have.property('$el', @view2Node.$el)
        expect(@view2NodeData).to.have.property('isComponentIndex', false)
        expect(@view2NodeData).to.have.property('isComponentPart', true)
        expect(@view2NodeData).to.have.property('isStandAlone', false)
        expect(@view2NodeData).to.have.property('componentId', @app1LayoutId)
        expect(@view2NodeData).to.have.property('applicationNode', @componentNodeData)
        expect(@view2NodeData).to.have.property('nodeName', 'TestView2')
        expect(@view2NodeData).to.have.property('nodeNameUnderscored', 'test_view2')
        expect(@view2NodeData).to.have.property('applicationName', 'TestComponent')
        expect(@view2NodeData).to.have.property('applicationNameUnderscored', 'test_component')
        expect(@view2NodeData).to.have.property('namespaceName', null)
        expect(@view2NodeData).to.have.property('namespaceNameUnderscored', null)

        expect(@view3NodeData).to.have.property('el', @view3Node.el)
        expect(@view3NodeData).to.have.property('$el', @view3Node.$el)
        expect(@view3NodeData).to.have.property('isComponentIndex', false)
        expect(@view3NodeData).to.have.property('isComponentPart', true)
        expect(@view3NodeData).to.have.property('isStandAlone', false)
        expect(@view3NodeData).to.have.property('componentId', @app1LayoutId)
        expect(@view3NodeData).to.have.property('applicationNode', @componentNodeData)
        expect(@view3NodeData).to.have.property('nodeName', 'TestView3')
        expect(@view3NodeData).to.have.property('nodeNameUnderscored', 'test_view3')
        expect(@view3NodeData).to.have.property('applicationName', 'TestComponent')
        expect(@view3NodeData).to.have.property('applicationNameUnderscored', 'test_component')
        expect(@view3NodeData).to.have.property('namespaceName', null)
        expect(@view3NodeData).to.have.property('namespaceNameUnderscored', null)

        expect(@view4NodeData).to.have.property('el', @view4Node.el)
        expect(@view4NodeData).to.have.property('$el', @view4Node.$el)
        expect(@view4NodeData).to.have.property('isComponentIndex', false)
        expect(@view4NodeData).to.have.property('isComponentPart', true)
        expect(@view4NodeData).to.have.property('isStandAlone', false)
        expect(@view4NodeData).to.have.property('componentId', @app1LayoutId)
        expect(@view4NodeData).to.have.property('applicationNode', @componentNodeData)
        expect(@view4NodeData).to.have.property('nodeName', 'TestView4')
        expect(@view4NodeData).to.have.property('nodeNameUnderscored', 'test_view4')
        expect(@view4NodeData).to.have.property('applicationName', 'TestComponent')
        expect(@view4NodeData).to.have.property('applicationNameUnderscored', 'test_component')
        expect(@view4NodeData).to.have.property('namespaceName', null)
        expect(@view4NodeData).to.have.property('namespaceNameUnderscored', null)

        expect(@view5NodeData).to.have.property('el', @view5Node.el)
        expect(@view5NodeData).to.have.property('$el', @view5Node.$el)
        expect(@view5NodeData).to.have.property('isComponentIndex', false)
        expect(@view5NodeData).to.have.property('isComponentPart', true)
        expect(@view5NodeData).to.have.property('isStandAlone', false)
        expect(@view5NodeData).to.have.property('componentId', @app1LayoutId)
        expect(@view5NodeData).to.have.property('applicationNode', @componentNodeData)
        expect(@view5NodeData).to.have.property('nodeName', 'TestView5')
        expect(@view5NodeData).to.have.property('nodeNameUnderscored', 'test_view5')
        expect(@view5NodeData).to.have.property('applicationName', 'TestComponent')
        expect(@view5NodeData).to.have.property('applicationNameUnderscored', 'test_component')
        expect(@view5NodeData).to.have.property('namespaceName', null)
        expect(@view5NodeData).to.have.property('namespaceNameUnderscored', null)

        expect(@view6NodeData).to.have.property('el', @view6Node.el)
        expect(@view6NodeData).to.have.property('$el', @view6Node.$el)
        expect(@view6NodeData).to.have.property('isComponentIndex', false)
        expect(@view6NodeData).to.have.property('isComponentPart', true)
        expect(@view6NodeData).to.have.property('isStandAlone', false)
        expect(@view6NodeData).to.have.property('componentId', @app1LayoutId)
        expect(@view6NodeData).to.have.property('applicationNode', @componentNodeData)
        expect(@view6NodeData).to.have.property('nodeName', 'TestView6')
        expect(@view6NodeData).to.have.property('nodeNameUnderscored', 'test_view6')
        expect(@view6NodeData).to.have.property('applicationName', 'TestComponent')
        expect(@view6NodeData).to.have.property('applicationNameUnderscored', 'test_component')
        expect(@view6NodeData).to.have.property('namespaceName', null)
        expect(@view6NodeData).to.have.property('namespaceNameUnderscored', null)

        expect(@view7NodeData).to.have.property('el', @view7Node.el)
        expect(@view7NodeData).to.have.property('$el', @view7Node.$el)
        expect(@view7NodeData).to.have.property('isComponentIndex', false)
        expect(@view7NodeData).to.have.property('isComponentPart', false)
        expect(@view7NodeData).to.have.property('isStandAlone', true)
        expect(@view7NodeData).to.have.property('componentId', null)
        expect(@view7NodeData).to.have.property('applicationNode', null)
        expect(@view7NodeData).to.have.property('nodeName', 'TestView7')
        expect(@view7NodeData).to.have.property('nodeNameUnderscored', 'test_view7')
        expect(@view7NodeData).to.have.property('applicationName', null)
        expect(@view7NodeData).to.have.property('applicationNameUnderscored', null)
        expect(@view7NodeData).to.have.property('namespaceName', 'TestNamespace')
        expect(@view7NodeData).to.have.property('namespaceNameUnderscored', 'test_namespace')

        expect(@component2NodeData).to.have.property('el', @component2Node.el)
        expect(@component2NodeData).to.have.property('$el', @component2Node.$el)
        expect(@component2NodeData).to.have.property('isComponentIndex', true)
        expect(@component2NodeData).to.have.property('isComponentPart', true)
        expect(@component2NodeData).to.have.property('isStandAlone', false)
        expect(@component2NodeData).to.have.property('componentId', @app2LayoutId)
        expect(@component2NodeData).to.have.property('applicationNode', null)
        expect(@component2NodeData).to.have.property('nodeName', 'Layout')
        expect(@component2NodeData).to.have.property('nodeNameUnderscored', 'layout')
        expect(@component2NodeData).to.have.property('applicationName', 'TestComponent2')
        expect(@component2NodeData).to.have.property('applicationNameUnderscored', 'test_component2')
        expect(@component2NodeData).to.have.property('namespaceName', null)
        expect(@component2NodeData).to.have.property('namespaceNameUnderscored', null)

        expect(@view8NodeData).to.have.property('el', @view8Node.el)
        expect(@view8NodeData).to.have.property('$el', @view8Node.$el)
        expect(@view8NodeData).to.have.property('isComponentIndex', false)
        expect(@view8NodeData).to.have.property('isComponentPart', true)
        expect(@view8NodeData).to.have.property('isStandAlone', false)
        expect(@view8NodeData).to.have.property('componentId', @app2LayoutId)
        expect(@view8NodeData).to.have.property('applicationNode', @component2NodeData)
        expect(@view8NodeData).to.have.property('nodeName', 'TestView8')
        expect(@view8NodeData).to.have.property('nodeNameUnderscored', 'test_view8')
        expect(@view8NodeData).to.have.property('applicationName', 'TestComponent2')
        expect(@view8NodeData).to.have.property('applicationNameUnderscored', 'test_component2')
        expect(@view8NodeData).to.have.property('namespaceName', null)
        expect(@view8NodeData).to.have.property('namespaceNameUnderscored', null)

        expect(@view9NodeData).to.have.property('el', @view9Node.el)
        expect(@view9NodeData).to.have.property('$el', @view9Node.$el)
        expect(@view9NodeData).to.have.property('isComponentIndex', false)
        expect(@view9NodeData).to.have.property('isComponentPart', false)
        expect(@view9NodeData).to.have.property('isStandAlone', true)
        expect(@view9NodeData).to.have.property('componentId', null)
        expect(@view9NodeData).to.have.property('applicationNode', null)
        expect(@view9NodeData).to.have.property('nodeName', 'TestView9')
        expect(@view9NodeData).to.have.property('nodeNameUnderscored', 'test_view9')
        expect(@view9NodeData).to.have.property('applicationName', null)
        expect(@view9NodeData).to.have.property('applicationNameUnderscored', null)
        expect(@view9NodeData).to.have.property('namespaceName', 'TestNamespace')
        expect(@view9NodeData).to.have.property('namespaceNameUnderscored', 'test_namespace')
